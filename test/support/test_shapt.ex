defmodule TestShapt do
  use Shapt,
    adapter: {Shapt.Adapters.Env, []},
    toggles: [
      feature_x: %{key: "A"},
      feature_y: %{key: "B"}
    ]
end
