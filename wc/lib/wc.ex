defmodule Wc do
  @moduledoc false

  use Nexus

  @impl true
  def version, do: "0.0.1"

  @bytes_doc "count number of bytes in a file"
  defcommand :c, type: :string, required: true, doc: @bytes_doc 

  @lines_doc "count number of lines in a file"
  defcommand :l, type: :string, required: true, doc: @lines_doc 

  @words_doc "count number of words in a file"
  defcommand :w, type: :string, required: true, doc: @words_doc 

  Nexus.help()
  Nexus.parse()

  def main([]) do
    io = IO.stream(:stdio, :line)
    bytes = count_file_bytes(io)
    lines = count_file_lines(io)
    words = count_file_words(io)
    IO.puts("#{lines}\t#{words}\t#{bytes}")
  end

  def main([cmd]) when cmd in ~w(c l w) do
    io = IO.stream(:stdio, :line)

    case cmd do
      "c" ->
        bytes = count_file_bytes(io)
        IO.puts(inspect(bytes))

      "l" ->
        lines = count_file_lines(io)
        IO.puts(inspect(lines))

      "w" ->
        words = count_file_words(io)
        IO.puts(inspect(words))
    end
  end

  def main([path]) do
    maybe_halt(path, fn ->
      bytes = count_file_bytes(path)
      lines = count_file_lines(path)
      words = count_file_words(path)
      IO.puts("#{lines}\t#{words}\t#{bytes}\t#{path}")
    end)
  end

  def main(args), do: __MODULE__.run(args)

  @impl Nexus.CLI
  def handle_input(:c, %{raw: <<"c", " ", path::binary>>}) do
    maybe_halt(path, fn ->
      file = File.stream!(path ,:line, [:read])
      bytes = count_file_bytes(file)
      IO.puts("#{bytes} #{path}")
    end)
  end

  def handle_input(:l, %{raw: <<"l", " ", path::binary>>}) do
    maybe_halt(path, fn ->
      file = File.stream!(path, :line, [:read])
      lines = count_file_lines(file)
      IO.puts("#{lines} #{path}")
    end)
  end

  def handle_input(:w, %{raw: <<"w", " ", path::binary>>}) do
    maybe_halt(path, fn ->
      file = File.stream!(path, :line, [:read])
      words = count_file_words(file)
      IO.puts("#{words} #{path}")
    end)
  end

  defp count_file_bytes(source) do
    Enum.reduce(source, 0, &Kernel.+(byte_size(&1), &2))
  end

  defp count_file_lines(source) do
    Enum.reduce(source, 0, fn _, acc -> acc + 1 end)
  end

  defp count_file_words(source) do
    source
    |> Stream.flat_map(&String.split(&1, ~r/\s/, trim: true))
    |> Enum.reduce(0, fn _, acc -> acc + 1 end)
  end

  defp maybe_halt(path, callback) do
    if File.exists?(path) do
      callback.()
    else
      exit({:shutdown, 1})
    end
  end
end
