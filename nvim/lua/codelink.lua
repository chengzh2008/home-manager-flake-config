-- Core logic for generating web "code links" (Azure DevOps / GitHub) from the
-- current buffer + cursor position. Kept free of plugin-spec concerns so it can
-- be unit tested in isolation (see nvim/tests/codelink_spec.lua).
local M = {}

local function urlencode(str)
  return (str:gsub("[^%w%-%._~/]", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

local function urldecode(str)
  return (str:gsub("%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end))
end

-- normalize an already-encoded-or-raw segment to a properly encoded one
local function seg(str)
  return urlencode(urldecode(str))
end

local function parse_remote(remote)
  remote = remote:gsub("%.git$", "")
  -- Azure DevOps: https://[user@]dev.azure.com/{org}/{project}/_git/{repo}
  local org, project, repo = remote:match("dev%.azure%.com/([^/]+)/(.+)/_git/([^/]+)")
  if org then return { kind = "azdo", org = org, project = project, repo = repo } end
  -- Azure DevOps SSH: git@ssh.dev.azure.com:v3/{org}/{project}/{repo}
  org, project, repo = remote:match("ssh%.dev%.azure%.com[:/]v3/([^/]+)/(.+)/([^/]+)")
  if org then return { kind = "azdo", org = org, project = project, repo = repo } end
  -- Azure DevOps legacy: https://{org}.visualstudio.com/{project}/_git/{repo}
  org, project, repo = remote:match("https?://([^%.]+)%.visualstudio%.com/(.+)/_git/([^/]+)")
  if org then return { kind = "azdo", org = org, project = project, repo = repo } end
  -- GitHub: https://github.com/{owner}/{repo} or git@github.com:{owner}/{repo}
  local owner, ghrepo = remote:match("github%.com[:/]([^/]+)/([^/]+)$")
  if owner then return { kind = "github", host = "github.com", owner = owner, repo = ghrepo } end
  return nil
end

local function get_range(visual)
  if visual then
    local s = vim.fn.line("v")
    local e = vim.fn.line(".")
    if s > e then
      s, e = e, s
    end
    return s, e
  end
  local l = vim.fn.line(".")
  return l, l
end

-- Build a web URL for the given remote info, repo-relative path and line range.
-- Pure: no editor/git access, so it is trivially unit testable.
function M.url_for(info, rel, branch, s, e)
  if rel:sub(1, 1) ~= "/" then
    rel = "/" .. rel
  end

  if info.kind == "github" then
    local base = "https://"
      .. info.host
      .. "/"
      .. seg(info.owner)
      .. "/"
      .. seg(info.repo)
      .. "/blob/"
      .. urlencode(branch)
      .. urlencode(rel)
    local anchor = "#L" .. s
    if e ~= s then
      anchor = anchor .. "-L" .. e
    end
    return base .. anchor
  end

  -- Azure DevOps
  local params = {
    "path=" .. urlencode(rel),
    "version=GB" .. urlencode(branch),
    "_a=contents",
    "line=" .. s,
    "lineEnd=" .. (e + 1),
    "lineStartColumn=1",
    "lineEndColumn=1",
    "lineStyle=plain",
  }
  local base = "https://dev.azure.com/"
    .. seg(info.org)
    .. "/"
    .. seg(info.project)
    .. "/_git/"
    .. seg(info.repo)
  return base .. "?" .. table.concat(params, "&")
end

function M.build(visual)
  local file = vim.fn.expand("%:p")
  if file == nil or file == "" then
    vim.notify("Code link: no file in buffer", vim.log.levels.WARN)
    return nil
  end
  local dir = vim.fn.fnamemodify(file, ":h")

  local function git(...)
    local cmd = { "git", "-C", dir }
    for _, a in ipairs({ ... }) do
      cmd[#cmd + 1] = a
    end
    local out = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
      return nil
    end
    return out[1]
  end

  local root = git("rev-parse", "--show-toplevel")
  local remote = git("remote", "get-url", "origin")
  local branch = git("rev-parse", "--abbrev-ref", "HEAD")
  if not root or not remote or not branch then
    vim.notify("Code link: not a git repo, or missing origin/branch", vim.log.levels.WARN)
    return nil
  end

  local info = parse_remote(remote)
  if not info then
    vim.notify("Code link: origin is not a supported remote (Azure DevOps / GitHub):\n" .. remote, vim.log.levels.WARN)
    return nil
  end

  root = root:gsub("/$", "")
  local rel = file:sub(#root + 1)

  local s, e = get_range(visual)
  return M.url_for(info, rel, branch, s, e)
end

function M.copy(visual)
  local url = M.build(visual)
  if not url then
    return
  end
  vim.fn.setreg("+", url)
  vim.fn.setreg('"', url)
  vim.notify("Code link copied:\n" .. url)
end

-- Pick an ordered list of URL-opener argv prefixes for the current OS.
local function openers()
  local is_wsl = vim.fn.has("wsl") == 1
  if not is_wsl then
    local rel = ""
    if vim.loop and vim.loop.os_uname then
      rel = (vim.loop.os_uname().release or ""):lower()
    end
    is_wsl = rel:find("microsoft") ~= nil or rel:find("wsl") ~= nil
  end

  if is_wsl then
    -- explorer.exe opens the default Windows browser; argv form keeps ADO
    -- URLs (which contain "&") intact without shell interpretation.
    return { { "wslview" }, { "explorer.exe" }, { "sensible-browser" }, { "xdg-open" } }
  elseif vim.fn.has("mac") == 1 then
    return { { "open" } }
  elseif vim.fn.has("win32") == 1 then
    return { { "explorer.exe" } }
  end
  return { { "xdg-open" }, { "gio", "open" }, { "sensible-browser" }, { "x-www-browser" } }
end

function M.open(visual)
  local url = M.build(visual)
  if not url then
    return
  end
  for _, prefix in ipairs(openers()) do
    if vim.fn.executable(prefix[1]) == 1 then
      local argv = {}
      for _, a in ipairs(prefix) do
        argv[#argv + 1] = a
      end
      argv[#argv + 1] = url
      local ok, job = pcall(vim.fn.jobstart, argv, { detach = true })
      if ok and type(job) == "number" and job > 0 then
        vim.notify("Opening code link:\n" .. url)
        return
      end
    end
  end
  -- Fallbacks: built-in opener, then just show the URL to copy.
  if vim.ui and vim.ui.open then
    local ok = pcall(vim.ui.open, url)
    if ok then
      return
    end
  end
  vim.fn.setreg("+", url)
  vim.notify("Code link: no URL opener found; copied to clipboard:\n" .. url, vim.log.levels.WARN)
end

-- Exposed for unit tests.
M.parse_remote = parse_remote

return M
