defmodule AdvancedScoreTracker do
  @moduledoc """
  Documentation for `AdvancedScoreTracker`.
  """
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  defp get_games_for(games, player, game) do
    Enum.filter(games, fn
      {{_, ^player, ^game}, _value} -> true
      _ -> false
    end)
  end

  defp get_current_game_for(games, player, game) do
    get_games_for(games, player, game)
    |> Enum.sort(fn {{index1, _, _}, _value}, {{index2, _, _}, _value2} -> index1 < index2 end)
    |> List.last()
  end

  @doc """
  Starts new game
  ## Examples

      iex> AdvancedScoreTracker.start_link
      iex> AdvancedScoreTracker.new(:player1, :ping_pong)
      iex> 0 = AdvancedScoreTracker.get(:player1, :ping_pong)

  """
  def new(player, game) do
    Agent.update(__MODULE__, fn games ->
      current_games = get_games_for(games, player, game)
      # since starts from 0
      new_index = Enum.count(current_games)
      Map.put(games, {new_index, player, game}, 0)
    end)
  end

  @doc """
  Get the score for the current game
  ## Examples

      iex> AdvancedScoreTracker.start_link
      iex> :ok = AdvancedScoreTracker.add(:player1, :ping_pong, 10)
      iex> AdvancedScoreTracker.new(:player1, :ping_pong)
      iex> AdvancedScoreTracker.add(:player1, :ping_pong, 10)
      iex> AdvancedScoreTracker.add(:player1, :ping_pong, 10)
      iex> 20 = AdvancedScoreTracker.get(:player1, :ping_pong)
  """
  def get(player, game) do
    Agent.get(__MODULE__, fn games ->
      {_key, value} = get_current_game_for(games, player, game)
      value
    end)
  end

  @doc """
  Add points to current game
  ## Examples

      iex> AdvancedScoreTracker.start_link
      iex> AdvancedScoreTracker.new(:player1, :ping_pong)
      iex> :ok = AdvancedScoreTracker.add(:player1, :ping_pong, 10)
      iex> :ok = AdvancedScoreTracker.add(:player1, :ping_pong, 10)

  """
  def add(player, game, score) do
    Agent.update(__MODULE__, fn games ->
      with {key, value} <- get_current_game_for(games, player, game) do
        Map.put(games, key, value + score)
      else
        nil -> games
      end
    end)
  end

  @doc """
  Get the history of scores for a player and game
  ## Examples

      iex> AdvancedScoreTracker.start_link
      iex> AdvancedScoreTracker.new(:player1, :ping_pong)
      iex> AdvancedScoreTracker.new(:player1, :ping_pong)
      iex> :ok = AdvancedScoreTracker.add(:player1, :ping_pong, 10)
      iex> :ok = AdvancedScoreTracker.add(:player1, :ping_pong, 10)
      iex> AdvancedScoreTracker.new(:player1, :ping_pong)
      iex> [0, 20, 0] = AdvancedScoreTracker.history(:player1, :ping_pong)

  """
  def history(player, game) do
    Agent.get(__MODULE__, fn games ->
      get_games_for(games, player, game)
      |> Enum.map(fn {_key, value} -> value end)
    end)
  end

  @doc """
  Get the history of scores for a player and game
  ## Examples

      iex> AdvancedScoreTracker.start_link
      iex> AdvancedScoreTracker.new(:player1, :ping_pong)
      iex> AdvancedScoreTracker.new(:player1, :ping_pong)
      iex> :ok = AdvancedScoreTracker.add(:player1, :ping_pong, 10)
      iex> :ok = AdvancedScoreTracker.add(:player1, :ping_pong, 10)
      iex> [0, 20] = AdvancedScoreTracker.history(:player1, :ping_pong)
      iex> 20 = AdvancedScoreTracker.high_score(:player1, :ping_pong)

  """
  def high_score(player, game) do
    Agent.get(__MODULE__, fn games ->
      get_games_for(games, player, game)
      |> Enum.map(fn {_key, value} -> value end)
      |> Enum.max()
    end)
  end
end
