defmodule Atlas.Factories do
  use ExMachina.Ecto, repo: Atlas.Repo

  # Factories

  def feature_factory do
    %Atlas.Feature{
      active: false,
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}")
    }
  end

  def permission_factory do
    %Atlas.Permission{
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}")
    }
  end

  def role_factory do
    %Atlas.Role{
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}")
    }
  end

  def user_factory do
    %Atlas.User{
      email: sequence(:slug, &"#{Faker.Internet.email()}-#{&1}"),
      first_name: Faker.Name.first_name(),
      last_name: Faker.Name.last_name(),
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}")
    }
  end

  def user_role_factory do
    %Atlas.UserRole{
      created_by: insert(:user),
      role: insert(:role),
      user: insert(:user)
    }
  end

  # Traits

  def with_permission(%Atlas.User{} = user, slug) do
    permission = Atlas.Repo.get_by(Atlas.Permission, slug: slug) || insert(:permission, slug: slug)
    role = insert(:role, permissions: [permission])
    insert(:user_role, role: role, user: user)
    user
  end

  def with_permissions(%Atlas.Role{} = role, number \\ 3) do
    insert_list(number, :permission, roles: [role])
    role
  end

  def with_roles(%Atlas.Permission{} = permission, number \\ 3) do
    insert_list(number, :role, permissions: [permission])
    permission
  end

  def with_user_roles(_record, number \\ 3)
  def with_user_roles(%Atlas.Role{} = role, number) do
    insert_list(number, :user_role, role: role)
    role
  end
  def with_user_roles(%Atlas.User{} = user, number) do
    insert_list(number, :user_role, user: user)
    user
  end
end
