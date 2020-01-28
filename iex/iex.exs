Application.put_env(:elixir, :ansi_enabled, true)

IEx.configure(
  history_size: -1,
  colors: [
    enabled: true,
    syntax_colors: [
      number: :blue,
      atom: :cyan,
      string: :yellow,
      boolean: :magenta,
      nil: :red
    ]
  ]
)
