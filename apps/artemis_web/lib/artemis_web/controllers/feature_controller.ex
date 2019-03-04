defmodule ArtemisWeb.FeatureController do
  use ArtemisWeb, :controller

  alias Artemis.CreateFeature
  alias Artemis.Feature
  alias Artemis.DeleteFeature
  alias Artemis.GetFeature
  alias Artemis.ListFeatures
  alias Artemis.UpdateFeature

  @preload []

  def index(conn, params) do
    authorize(conn, "features:list", fn () ->
      params = Map.put(params, :paginate, true)
      features = ListFeatures.call(params, current_user(conn))

      render(conn, "index.html", features: features)
    end)
  end

  def new(conn, _params) do
    authorize(conn, "features:create", fn () ->
      feature = %Feature{}
      changeset = Feature.changeset(feature)

      render(conn, "new.html", changeset: changeset, feature: feature)
    end)
  end

  def create(conn, %{"feature" => params}) do
    authorize(conn, "features:create", fn () ->
      case CreateFeature.call(params, current_user(conn)) do
        {:ok, feature} ->
          conn
          |> put_flash(:info, "Feature created successfully.")
          |> redirect(to: Routes.feature_path(conn, :show, feature))

        {:error, %Ecto.Changeset{} = changeset} ->
          feature = %Feature{}

          render(conn, "new.html", changeset: changeset, feature: feature)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "features:show", fn () ->
      feature = GetFeature.call!(id, current_user(conn))

      render(conn, "show.html", feature: feature)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "features:update", fn () ->
      feature = GetFeature.call(id, current_user(conn), preload: @preload)
      changeset = Feature.changeset(feature)

      render(conn, "edit.html", changeset: changeset, feature: feature)
    end)
  end

  def update(conn, %{"id" => id, "feature" => params}) do
    authorize(conn, "features:update", fn () ->
      case UpdateFeature.call(id, params, current_user(conn)) do
        {:ok, feature} ->
          conn
          |> put_flash(:info, "Feature updated successfully.")
          |> redirect(to: Routes.feature_path(conn, :show, feature))

        {:error, %Ecto.Changeset{} = changeset} ->
          feature = GetFeature.call(id, current_user(conn), preload: @preload)

          render(conn, "edit.html", changeset: changeset, feature: feature)
      end
    end)
  end

  def delete(conn, %{"id" => id}) do
    authorize(conn, "features:delete", fn () ->
      {:ok, _feature} = DeleteFeature.call(id, current_user(conn))

      conn
      |> put_flash(:info, "Feature deleted successfully.")
      |> redirect(to: Routes.feature_path(conn, :index))
    end)
  end
end
