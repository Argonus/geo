defmodule Geo.Postgrex do
  alias Postgrex.TypeInfo

  @moduledoc """
    Encoder, Decoder, and Formatter to be used with Postgrex for PostGIS data types

    iex(1)>     opts = [hostname: "localhost",
    ...(1)>     username: "postgres", database: "geo_postgrex_test",
    ...(1)>     encoder: &Geo.Postgrex.encoder/3, decoder: &Geo.Postgrex.decoder/4,
    ...(1)>     formatter: &Geo.Postgrex.formatter/1 ]
    [hostname: "localhost", username: "postgres", database: "geo_postgrex_test",
     encoder: &Geo.Postgrex.encoder/3, decoder: &Geo.Postgrex.decoder/4,
     formatter: &Geo.Postgrex.formatter/1]

    iex(2)> {:ok, pid} = Postgrex.Connection.start_link(opts)
    {:ok, #PID<0.115.0>}

    iex(3)> geo = %Geo.Geometry{type: :point, coordinates: [30, -90], srid: 4326}
    %Geo.Geometry{coordinates: [30, -90], srid: 4326, type: :point}
    
    iex(4)> {:ok, _} = Postgrex.Connection.query(pid, "CREATE TABLE point_test (id int, geom geometry(Point, 4326))")
    {:ok,
     %Postgrex.Result{columns: nil, command: :create_table, num_rows: 0, rows: nil}}
    
    iex(5)> {:ok, _} = Postgrex.Connection.query(pid, "INSERT INTO point_test VALUES ($1, $2)", [42, geo])
    {:ok, %Postgrex.Result{columns: nil, command: :insert, num_rows: 1, rows: nil}}
    
    iex(6)> Postgrex.Connection.query(pid, "SELECT * FROM point_test")
    {:ok,
     %Postgrex.Result{columns: ["id", "geom"], command: :select, num_rows: 1,
      rows: [{42,
        %Geo.Geometry{coordinates: [30.0, -90.0], srid: 4326, type: :point}}]}}

  """

  def decoder(%TypeInfo{sender: "geometry", type: "geometry"}, _format , _, value) do
    Geo.WKB.decode(value)
  end

  def decoder(%TypeInfo{}, _format, default, bin) do
    default.(bin)
  end

  def encoder(%TypeInfo{sender: "geometry", type: "geometry"}, _, value) do
    Geo.WKT.encode(value)
  end

  def encoder(%TypeInfo{}, default, value) do
    default.(value)
  end

  def formatter(%TypeInfo{sender: "geometry"}), do: :text
  def formatter(%TypeInfo{}), do: nil
end