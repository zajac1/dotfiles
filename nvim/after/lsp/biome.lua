return {
  root_dir = function(bufnr, on_dir)
    local biome_root = vim.fs.root(bufnr, { "biome.json", "biome.jsonc" })
    if biome_root then
      on_dir(biome_root)
    end
  end,
}
