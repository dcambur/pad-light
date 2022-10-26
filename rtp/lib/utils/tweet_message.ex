defmodule Tweet do
  @enforce_keys [:id, :created_at, :text, :username, :retweet_count, :favorite_count, :from_retweet]
  defstruct [:id, :created_at, :text, :username, :retweet_count, :favorite_count, :from_retweet]
end
