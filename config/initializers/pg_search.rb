PgSearch.multisearch_options = {
  using: {
    tsearch: { prefix: true },  # Allows prefix matching (e.g., "app" matches "apple")
    trigram: {}                 # Enables fuzzy matching (e.g., "ple" matches "apple")
  }
}
