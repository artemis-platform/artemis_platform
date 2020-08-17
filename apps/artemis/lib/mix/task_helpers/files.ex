defmodule Mix.TaskHelpers.Files do
  import Mix.TaskHelpers.Commands

  @moduledoc """
  Functions for managing files and file contents.

  ## Elixir Libraries

  [loki](https://github.com/khusnetdinov/loki)
  """

  @doc """
  Copy files and directories
  """
  def copy(source, target), do: execute("cp -pr #{source} #{target}")

  @doc """
  Replace contents of files in the given path
  """
  def replace(path, source, target) do
    execute(
      "find #{path} -type f -not -path '*node_modules*' | xargs /usr/bin/sed -i '' -e \"s/#{source}/#{target}/g\""
    )
  end

  @doc """
  Rename directories and files
  """
  def rename(path, source, target) do
    execute("""
      find #{path} -type d | grep "#{source}" | while read DIR ; do
        NEW_DIR=`echo ${DIR} | gsed -e "s/#{source}/#{target}/g"`
        mv "${DIR}/" "${NEW_DIR}"
      done
    """)

    execute("""
      find #{path} -type f | grep "#{source}" | while read FILE ; do
        NEW_FILE=`echo ${FILE} | gsed -e "s/#{source}/#{target}/g"`
        mv "${FILE}" "${NEW_FILE}"
      done
    """)
  end
end
