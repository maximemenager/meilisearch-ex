defmodule Meilisearch.Index do
  @moduledoc """
  Retreive Meilisearch health status.
  """

  use Ecto.Schema

  schema "indexes" do
    field(:uid, :string)
    field(:primaryKey, :string)
    field(:createdAt, :naive_datetime)
    field(:updatedAt, :naive_datetime)
  end

  @type t :: %__MODULE__{
          uid: String.t(),
          primaryKey: String.t(),
          createdAt: DateTime.t(),
          updatedAt: DateTime.t()
        }

  def from_json(data) when is_list(data), do: Enum.map(data, &from_json(&1))

  def from_json(data) when is_map(data) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(data, [:uid, :primaryKey, :createdAt, :updatedAt])
    |> Ecto.Changeset.apply_changes()
  end

  @doc """
  List indexes of your Meilsiearch instance.
  [meili doc](https://docs.meilisearch.com/reference/api/indexes.html#index-object)

  ## Examples

      iex> client = Meilisearch.Client.new(endpoint: "http://localhost:7700", key: "master_key_test")
      iex> Meilisearch.Index.list(client, limit: 20, offset: 0)
      {:ok, %{offset: 0, limit: 20, total: 1, results: [%{
        uid: "movies",
        primaryKey: "id",
        createdAt: ~N[2021-08-12 10:00:00],
        updatedAt: ~N[2021-08-12 10:00:00]
      }]}}

  """
  @spec list(Tesla.Client.t(), offset: integer(), limit: integer()) ::
          {:ok,
           %{
             results: list(Index.t()),
             offśet: integer(),
             limit: integer(),
             total: integer()
           }}
          | :error
  def list(client, opts \\ []) do
    with {:ok, data} <-
           client
           |> Tesla.get("/indexes", query: opts)
           |> Meilisearch.Client.handle_response() do
      {:ok, Map.put(data, :results, from_json(data.results))}
    end
  end

  @doc """
  Get an Index of your Meilsiearch instance.
  [meili doc](https://docs.meilisearch.com/reference/api/indexes.html#get-one-index)

  ## Examples

      iex> client = Meilisearch.Client.new(endpoint: "http://localhost:7700", key: "master_key_test")
      iex> Meilisearch.Index.get(client, "movies")
      {:ok, %{
        uid: "movies",
        primaryKey: "id",
        createdAt: ~N[2021-08-12 10:00:00],
        updatedAt: ~N[2021-08-12 10:00:00]
      }}

  """
  @spec get(Tesla.Client.t(), String.t()) :: {:ok, Index.t()} | :error
  def get(client, index_uid) do
    with {:ok, data} <-
           client
           |> Tesla.get("/indexes/:index_uid", opts: [path_params: [index_uid: index_uid]])
           |> Meilisearch.Client.handle_response() do
      {:ok, from_json(data)}
    end
  end

  @doc """
  Create a new Index in your Meilsiearch instance.
  [meili doc](https://docs.meilisearch.com/reference/api/indexes.html#create-an-index)

  ## Examples

      iex> client = Meilisearch.Client.new(endpoint: "http://localhost:7700", key: "master_key_test")
      iex> Meilisearch.Index.create(client, %{uid: "actors", primaryKey: "id"})
      {:ok, %{
        taskUid: 0,
        indexUid: "movies",
        status: :enqueued,
        type: :indexCreation,
        enqueuedAt: ~N[2021-08-12 10:00:00]
      }}

  """
  @spec create(Tesla.Client.t(), %{uid: String.t(), primaryKey: String.t() | nil}) ::
          {:ok, Meilisearch.Task.t()} | :error
  def create(client, params) do
    with {:ok, data} <-
           client
           |> Tesla.post("/indexes", params)
           |> Meilisearch.Client.handle_response() do
      {:ok, Meilisearch.Task.from_json(data)}
    end
  end

  @doc """
  Update a new Index in your Meilsiearch instance.
  [meili doc](https://docs.meilisearch.com/reference/api/indexes.html#update-an-index)

  ## Examples

      iex> client = Meilisearch.Client.new(endpoint: "http://localhost:7700", key: "master_key_test")
      iex> Meilisearch.Index.update(client, "actors", %{primaryKey: "id"})
      {:ok, %{
        taskUid: 0,
        indexUid: "movies",
        status: :enqueued,
        type: :indexUpdate,
        enqueuedAt: ~N[2021-08-12 10:00:00]
      }}

  """
  @spec update(Tesla.Client.t(), String.t(), %{primaryKey: String.t() | nil}) ::
          {:ok, Meilisearch.Task.t()} | :error
  def update(client, index_uid, params) do
    with {:ok, data} <-
           client
           |> Tesla.patch("/indexes/:index_uid", params, opts: [path_params: [index_uid: index_uid]])
           |> Meilisearch.Client.handle_response() do
      {:ok, Meilisearch.Task.from_json(data)}
    end
  end

  @doc """
  Delete a new Index in your Meilsiearch instance.
  [meili doc](https://docs.meilisearch.com/reference/api/indexes.html#delete-an-index)

  ## Examples

      iex> client = Meilisearch.Client.new(endpoint: "http://localhost:7700", key: "master_key_test")
      iex> Meilisearch.Index.delete(client, "actors")
      {:ok, %{
        taskUid: 0,
        indexUid: "movies",
        status: :enqueued,
        type: :indexDeletion,
        enqueuedAt: ~N[2021-08-12 10:00:00]
      }}

  """
  @spec delete(Tesla.Client.t(), String.t()) ::
          {:ok, Meilisearch.Task.t()} | :error
  def delete(client, index_uid) do
    with {:ok, data} <-
           client
           |> Tesla.delete("/indexes/:index_uid", opts: [path_params: [index_uid: index_uid]])
           |> Meilisearch.Client.handle_response() do
      {:ok, Meilisearch.Task.from_json(data)}
    end
  end

  @doc """
  Create a new Index in your Meilsiearch instance.
  [meili doc](https://docs.meilisearch.com/reference/api/indexes.html#create-an-index)

  ## Examples

      iex> client = Meilisearch.Client.new(endpoint: "http://localhost:7700", key: "master_key_test")
      iex> Meilisearch.Index.swap(client, [%{indexes: ["movies", "actors"]}])
      {:ok, %{
        taskUid: 0,
        indexUid: "movies",
        status: :enqueued,
        type: :indexSwap,
        enqueuedAt: ~N[2021-08-12 10:00:00]
      }}

  """
  @spec swap(Tesla.Client.t(), list(%{indexes: list(String.t())})) ::
          {:ok, Meilisearch.Task.t()} | :error
  def swap(client, params) do
    with {:ok, data} <-
           client
           |> Tesla.post("/swap-indexes", params)
           |> Meilisearch.Client.handle_response() do
      {:ok, Meilisearch.Task.from_json(data)}
    end
  end
end
