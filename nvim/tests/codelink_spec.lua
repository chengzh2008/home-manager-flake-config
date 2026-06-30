-- Unit tests for the `codelink` module.
--
-- Run with a plain Lua interpreter (no Neovim needed); `vim` is mocked:
--
--   nix-shell -p lua --run "lua nvim/tests/codelink_spec.lua"
--
-- Exits non-zero if any assertion fails.

-- Make `require("codelink")` resolve to ../lua/codelink.lua relative to this file.
local here = (arg and arg[0] or ""):match("(.*/)") or "./"
package.path = here .. "../lua/?.lua;" .. package.path

-- ---------------------------------------------------------------------------
-- Minimal `vim` mock. Tests mutate `env` to control the buffer/git state.
-- ---------------------------------------------------------------------------
local env = {}

_G.vim = {
  log = { levels = { WARN = 1, ERROR = 2 } },
  v = { shell_error = 0 },
  notify = function() end,
  ui = {},
  fn = {
    expand = function()
      return env.file
    end,
    fnamemodify = function(f)
      return f:match("(.*)/[^/]*$")
    end,
    line = function(w)
      if w == "v" then
        return env.vline
      end
      return env.line
    end,
    setreg = function() end,
    systemlist = function(cmd)
      vim.v.shell_error = env.shell_error or 0
      local last = cmd[#cmd]
      if last == "--show-toplevel" then
        return { env.root }
      elseif last == "origin" then
        return { env.remote }
      elseif last == "HEAD" then
        return { env.branch }
      end
      return {}
    end,
  },
}

local codelink = require("codelink")

-- ---------------------------------------------------------------------------
-- Tiny assertion harness.
-- ---------------------------------------------------------------------------
local total, failed = 0, 0

local function check(ok, name, detail)
  total = total + 1
  if ok then
    io.write("ok   " .. name .. "\n")
  else
    failed = failed + 1
    io.write("FAIL " .. name .. "\n")
    if detail then
      io.write("     " .. detail .. "\n")
    end
  end
end

local function eq(got, want, name)
  check(got == want, name, string.format("expected: %s\n     got:      %s", tostring(want), tostring(got)))
end

-- ---------------------------------------------------------------------------
-- parse_remote
-- ---------------------------------------------------------------------------
do
  local i = codelink.parse_remote("https://powerbi@dev.azure.com/powerbi/Power%20BI/_git/powerbi")
  eq(i and i.kind, "azdo", "parse: azdo https kind")
  eq(i and i.org, "powerbi", "parse: azdo https org")
  eq(i and i.project, "Power%20BI", "parse: azdo https project")
  eq(i and i.repo, "powerbi", "parse: azdo https repo")

  i = codelink.parse_remote("git@ssh.dev.azure.com:v3/powerbi/Power BI/powerbi")
  eq(i and i.kind, "azdo", "parse: azdo ssh kind")
  eq(i and i.project, "Power BI", "parse: azdo ssh project")

  i = codelink.parse_remote("https://contoso.visualstudio.com/MyProj/_git/MyRepo")
  eq(i and i.kind, "azdo", "parse: azdo legacy kind")
  eq(i and i.org, "contoso", "parse: azdo legacy org")

  i = codelink.parse_remote("https://github.com/octo/My-Repo.git")
  eq(i and i.kind, "github", "parse: github https kind")
  eq(i and i.owner, "octo", "parse: github https owner")
  eq(i and i.repo, "My-Repo", "parse: github https repo")

  i = codelink.parse_remote("git@github.com:octo/My-Repo.git")
  eq(i and i.kind, "github", "parse: github ssh kind")
  eq(i and i.owner, "octo", "parse: github ssh owner")

  eq(codelink.parse_remote("https://bitbucket.org/o/r.git"), nil, "parse: unsupported -> nil")
end

-- ---------------------------------------------------------------------------
-- url_for (pure URL construction)
-- ---------------------------------------------------------------------------
do
  local gh = { kind = "github", host = "github.com", owner = "octo", repo = "My-Repo" }
  eq(
    codelink.url_for(gh, "/src/app/Main.cs", "master", 429, 429),
    "https://github.com/octo/My-Repo/blob/master/src/app/Main.cs#L429",
    "url_for: github single line"
  )
  eq(
    codelink.url_for(gh, "/src/app/Main.cs", "master", 429, 431),
    "https://github.com/octo/My-Repo/blob/master/src/app/Main.cs#L429-L431",
    "url_for: github range"
  )
  eq(
    codelink.url_for(gh, "src/My File.cs", "feat/x", 5, 5),
    "https://github.com/octo/My-Repo/blob/feat/x/src/My%20File.cs#L5",
    "url_for: github encodes spaces, adds leading slash"
  )

  local ado = { kind = "azdo", org = "powerbi", project = "Power%20BI", repo = "powerbi" }
  eq(
    codelink.url_for(ado, "/Sql/CloudBI/AS/src/Datamarts/Managers/Managers/DatamartsUpdateManager.cs", "master", 429, 429),
    "https://dev.azure.com/powerbi/Power%20BI/_git/powerbi?path=/Sql/CloudBI/AS/src/Datamarts/Managers/Managers/DatamartsUpdateManager.cs&version=GBmaster&_a=contents&line=429&lineEnd=430&lineStartColumn=1&lineEndColumn=1&lineStyle=plain",
    "url_for: azdo matches reference URL"
  )
end

-- ---------------------------------------------------------------------------
-- build (end-to-end with mocked git)
-- ---------------------------------------------------------------------------
do
  env = {
    file = "/repo/src/app/Main.cs",
    root = "/repo",
    branch = "master",
    line = 429,
    vline = 429,
    remote = "https://github.com/octo/My-Repo.git",
  }
  eq(codelink.build(false), "https://github.com/octo/My-Repo/blob/master/src/app/Main.cs#L429", "build: github normal mode")

  env.vline, env.line = 429, 431
  eq(codelink.build(true), "https://github.com/octo/My-Repo/blob/master/src/app/Main.cs#L429-L431", "build: github visual range")

  -- reversed selection should normalize
  env.vline, env.line = 431, 429
  eq(codelink.build(true), "https://github.com/octo/My-Repo/blob/master/src/app/Main.cs#L429-L431", "build: github reversed selection")

  env.remote, env.line, env.vline = "https://powerbi@dev.azure.com/powerbi/Power%20BI/_git/powerbi", 429, 429
  eq(
    codelink.build(false),
    "https://dev.azure.com/powerbi/Power%20BI/_git/powerbi?path=/src/app/Main.cs&version=GBmaster&_a=contents&line=429&lineEnd=430&lineStartColumn=1&lineEndColumn=1&lineStyle=plain",
    "build: azdo normal mode"
  )

  -- unsupported remote -> nil
  env.remote = "https://bitbucket.org/o/r.git"
  eq(codelink.build(false), nil, "build: unsupported remote -> nil")

  -- not a git repo (git fails) -> nil
  env.remote, env.shell_error = "https://github.com/octo/My-Repo.git", 128
  eq(codelink.build(false), nil, "build: git failure -> nil")
  env.shell_error = 0
end

-- ---------------------------------------------------------------------------
io.write(string.format("\n%d passed, %d failed (of %d)\n", total - failed, failed, total))
os.exit(failed == 0 and 0 or 1)
