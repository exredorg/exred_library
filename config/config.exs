use Mix.Config

config :exred_library,
  ecto_repos: [Exred.Library.SqliteRepo]

config :exred_library, Exred.Library.SqliteRepo,
  adapter: Sqlite.Ecto2,
  database: "/tmp/exred.sqlite3"
