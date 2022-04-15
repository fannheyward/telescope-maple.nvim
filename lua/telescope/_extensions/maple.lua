local conf = require('telescope.config').values
local utils = require "telescope.utils"
local finders = require('telescope.finders')
local sorters = require "telescope.sorters"
local pickers = require('telescope.pickers')

---@diagnostic disable-next-line: undefined-global
local vim = vim
local pcall = pcall
local tonumber = tonumber

local maple = function(opts)
  local make_display = function(filename, text)
    local display, hl_group = utils.transform_devicons(filename, text)

    if hl_group then
      return display, { { { 1, 3 }, hl_group } }
    else
      return display
    end
  end

  local maple_finder = finders.new_job(
    function(prompt)
      if not prompt or prompt == "" then
        return
      end

      return { 'maple', 'grep', prompt }
    end,

    function(entry)
      if not entry or entry == "" then
        return
      end

      local ok, obj = pcall(vim.json.decode, entry)
      if not ok then
        return
      end
      local text = obj.text
      if not text or text == "" then
        return
      end

      local parts = vim.split(text, ':')
      return {
        valid = true,
        path = parts[1],
        filename = parts[1],
        lnum = tonumber(parts[2]),
        col = tonumber(parts[3]),
        text = parts[4],
        value = text,
        ordinal = text,
        display = make_display(parts[1], text),
      }
    end,

    opts.max_results,
    opts.cwd
  )

  pickers.new(opts, {
    prompt_title = "maple grep",
    previewer = conf.grep_previewer(opts),
    sorter = sorters.highlighter_only(opts),
    finder = maple_finder,
  }):find()
end

return require('telescope').register_extension({
  exports = {
    maple = maple,
  },
})

-- vim: set sw=2 ts=2 sts=2 et
