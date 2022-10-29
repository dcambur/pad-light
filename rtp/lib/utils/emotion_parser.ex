defmodule Rtp.Utils.EmotionParser do
  @moduledoc """
  utility module for processing emotion value strings into
  key-value data structure in Elixir
  """
  @format_t "\t"
  @format_r "\r"
  @format_n "\n"

  @doc """
  handles convertation to key-value structure
  """
  def process(emotion_values) do
    emotion_map(emotion_values)
  end

  defp emotion_map(emotion_values) do
    String.split(emotion_values, @format_r)
    |> Enum.map(fn x -> String.split(String.trim(x, @format_n), @format_t) end)
    |> Map.new(fn [k, v] -> {k, v} end)
  end
end
