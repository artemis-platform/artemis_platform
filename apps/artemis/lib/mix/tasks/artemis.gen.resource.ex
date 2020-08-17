defmodule Mix.Tasks.Artemis.Gen.Resource do
  use Mix.Task

  import Mix.TaskHelpers.Colors
  import Mix.TaskHelpers.Commands
  import Mix.TaskHelpers.Files
  import Mix.TaskHelpers.Prompts
  import Mix.TaskHelpers.Strings

  @app_web "artemis_web"

  @apps [
    "artemis",
    "artemis_log"
  ]

  @divider "…………………………………………………………………………………………………………………………………"

  @steps [
    "Database Configuration",
    "Schema",
    "Test Factory",
    "Schema Tests",
    "Contexts",
    "Context Tests",
    "Permissions",
    "Routes",
    "Controller",
    "View",
    "Templates",
    "Controller Tests",
    "Browser Tests",
    "Navigation"
  ]

  @impl Mix.Task
  def run(args) do
    print_welcome_message()

    config = get_config(args)

    if config.verbose?, do: print(config)

    execute_steps(config)
  end

  # Config

  defp print_welcome_message() do
    print("""
    The `artemis.gen.resource` tool generates a new resource, using an
    existing resource's files as a template.
    """)
  end

  defp get_config(args) do
    %{}
    |> parse_args(args)
    |> get_initial_user_options()
    |> add_cases()
  end

  defp parse_args(config, args) do
    help_flags = ["-h", "--help"]
    help? = Enum.any?(args, &Enum.member?(help_flags, &1))

    verbose_flags = ["-v", "--verbose"]
    verbose? = Enum.any?(args, &Enum.member?(verbose_flags, &1))

    config
    |> Map.put(:app_web, @app_web)
    |> Map.put(:help?, help?)
    |> Map.put(:verbose?, verbose?)
  end

  defp get_initial_user_options(config) do
    app = choose("App?", @apps, default: "artemis")

    existing_resource_prompt = [
      "Name of existing resource to use as a template? ",
      gray("for example `Feature`")
    ]

    source_single = prompt(existing_resource_prompt, required: true)
    source_plural = prompt("Plural form of existing resource?", default: source_single <> "s", required: true)

    target_single = prompt("Name of new resource?", required: true)
    target_plural = prompt("Plural form of new resource?", default: target_single <> "s", required: true)

    step = choose("Start on which step?", @steps, default: hd(@steps))

    user_options = %{
      app: app,
      source_single: source_single,
      source_plural: source_plural,
      target_single: target_single,
      target_plural: target_plural,
      step: step
    }

    config
    |> Map.put(:app, app)
    |> Map.put(:step, step)
    |> Map.put(:user_options, user_options)
  end

  defp add_cases(config) do
    # Space Case
    # example: `iPhone Ten`
    source_single_spacecase = config.user_options.source_single
    target_single_spacecase = config.user_options.target_single

    source_plural_spacecase = config.user_options.source_plural
    target_plural_spacecase = config.user_options.target_plural

    # Space Case Lower
    # example: `iphone ten`
    source_plural_spacecase_lower = lowercase(source_plural_spacecase)
    target_plural_spacecase_lower = lowercase(target_plural_spacecase)

    source_single_spacecase_lower = lowercase(source_single_spacecase)
    target_single_spacecase_lower = lowercase(target_single_spacecase)

    # Space Case Upper
    # example: `IPHONE TEN`
    source_plural_spacecase_upper = uppercase(source_plural_spacecase)
    target_plural_spacecase_upper = uppercase(target_plural_spacecase)

    source_single_spacecase_upper = uppercase(source_single_spacecase)
    target_single_spacecase_upper = uppercase(target_single_spacecase)

    # Module Case
    # example: `IphoneTen`
    source_plural_modulecase = modulecase(source_plural_spacecase)
    target_plural_modulecase = modulecase(target_plural_spacecase)

    source_single_modulecase = modulecase(source_single_spacecase)
    target_single_modulecase = modulecase(target_single_spacecase)

    # Snake Case Lower
    # example: `iphone_ten`
    source_plural_snakecase_lower = snakecase(source_plural_modulecase)
    target_plural_snakecase_lower = snakecase(target_plural_modulecase)

    source_single_snakecase_lower = snakecase(source_single_modulecase)
    target_single_snakecase_lower = snakecase(target_single_modulecase)

    # Snake Case Upper
    # example: `IPHONE_TEN`
    source_plural_snakecase_upper = uppercase(source_plural_snakecase_lower)
    target_plural_snakecase_upper = uppercase(target_plural_snakecase_lower)

    source_single_snakecase_upper = uppercase(source_single_snakecase_lower)
    target_single_snakecase_upper = uppercase(target_single_snakecase_lower)

    # Dash Case Lower
    # example: `iphone-ten`
    source_plural_dashcase = dashcase(source_plural_snakecase_lower)
    target_plural_dashcase = dashcase(target_plural_snakecase_lower)

    source_single_dashcase = dashcase(source_single_snakecase_lower)
    target_single_dashcase = dashcase(target_single_snakecase_lower)

    case_order = [
      :spacecase,
      :modulecase,
      :dashcase,
      :snakecase_lower,
      :snakecase_upper,
      :spacecase_lower,
      :spacecase_upper
    ]

    cases = %{
      source: %{
        plural: %{
          dashcase: source_plural_dashcase,
          modulecase: source_plural_modulecase,
          snakecase_lower: source_plural_snakecase_lower,
          snakecase_upper: source_plural_snakecase_upper,
          spacecase: source_plural_spacecase,
          spacecase_lower: source_plural_spacecase_lower,
          spacecase_upper: source_plural_spacecase_upper
        },
        single: %{
          dashcase: source_single_dashcase,
          modulecase: source_single_modulecase,
          snakecase_lower: source_single_snakecase_lower,
          snakecase_upper: source_single_snakecase_upper,
          spacecase: source_single_spacecase,
          spacecase_lower: source_single_spacecase_lower,
          spacecase_upper: source_single_spacecase_upper
        }
      },
      target: %{
        plural: %{
          dashcase: target_plural_dashcase,
          modulecase: target_plural_modulecase,
          snakecase_lower: target_plural_snakecase_lower,
          snakecase_upper: target_plural_snakecase_upper,
          spacecase: target_plural_spacecase,
          spacecase_lower: target_plural_spacecase_lower,
          spacecase_upper: target_plural_spacecase_upper
        },
        single: %{
          dashcase: target_single_dashcase,
          modulecase: target_single_modulecase,
          snakecase_lower: target_single_snakecase_lower,
          snakecase_upper: target_single_snakecase_upper,
          spacecase: target_single_spacecase,
          spacecase_lower: target_single_spacecase_lower,
          spacecase_upper: target_single_spacecase_upper
        }
      }
    }

    config
    |> Map.put(:case_order, case_order)
    |> Map.put(:cases, cases)
  end

  # Steps

  defp execute_steps(config) do
    starting_index = get_step_index(config.step)

    Enum.reduce(@steps, starting_index, fn step, current_index ->
      cond do
        current_index > get_step_index(step) ->
          print("Skipped step #{step}")
          print(@divider)

          current_index

        current_index == get_step_index(step) ->
          print("Executing step #{step}")
          execute_step(step, config)
          print(green("✓") ++ [" ", "Completed step #{step}"])
          print(@divider)

          next_step? = length(@steps) != current_index

          case next_step? && continue_to_next_step?(current_index) do
            true ->
              print(@divider)
              current_index + 1

            false ->
              line_break()
              print(green("✓ All Steps Completed"))
              line_break()
              exit_task(0)
          end
      end
    end)
  end

  defp continue_to_next_step?(index) do
    next_step = Enum.at(@steps, index)

    response =
      "Continue to next step #{next_step}?"
      |> choose(["yes", "no"], default: "yes")
      |> Kernel.||("")
      |> lowercase()

    Enum.member?(["y", "ye", "yes"], response)
  end

  defp get_step_index(value) do
    Enum.find_index(@steps, &(&1 == value)) + 1
  end

  defp execute_with_all_cases(config, callback) do
    Enum.map([:plural, :single], fn type ->
      Enum.map(config.case_order, fn current_case ->
        source = get_in(config.cases.source, [type, current_case])
        target = get_in(config.cases.target, [type, current_case])

        callback.(source, target)
      end)
    end)
  end

  defp execute_step("Database Configuration", config) do
    line_break()
    action("Create database configuration")
    line_break()

    priv_dir = "apps/#{config.app}/priv/repo/migrations"
    priv_dir? = File.exists?(priv_dir)

    if priv_dir? do
      execute("cd apps/#{config.app} && mix ecto.gen.migration create_#{config.cases.target.plural.snakecase_lower}")
    end

    priv_path = execute("ls #{priv_dir}/*_create_#{config.cases.target.plural.snakecase_lower}.exs")

    test_dir = "apps/#{config.app}/test/repo/migrations"
    test_dir? = File.exists?(test_dir)

    if test_dir? do
      priv_file =
        priv_path
        |> String.split("/")
        |> List.last()

      test_path = "apps/#{config.app}/test/repo/migrations/#{priv_file}"

      execute("mv #{priv_path} #{test_path}")
    end

    test_path = execute("ls #{test_dir}/*_create_#{config.cases.target.plural.snakecase_lower}.exs")

    target_path = if test_dir?, do: test_path, else: priv_path

    source_path =
      cond do
        test_dir? -> execute("ls #{test_dir}/*_create_#{config.cases.source.single.snakecase_lower}*")
        priv_dir? -> execute("ls #{priv_dir}/*_create_#{config.cases.source.single.snakecase_lower}*")
        true -> nil
      end

    print("""
      Open the database migration file `#{target_path}`, adding
      fields, associations and indexes.

      Use the source resource migration file `#{source_path}` as an example.
    """)
  end

  defp execute_step("Schema", config) do
    root_directory = "apps/#{config.app}/lib/#{config.app}/schemas"
    source_directory = "#{root_directory}/#{config.cases.source.single.snakecase_lower}.ex"
    target_directory = "#{root_directory}/#{config.cases.target.single.snakecase_lower}.ex"

    copy("#{source_directory}", "#{target_directory}")

    execute_with_all_cases(config, fn source, target ->
      replace("#{target_directory}", source, target)
    end)
  end

  defp execute_step("Test Factory", config) do
    line_break()
    action("Create test factory")
    line_break()

    print("""
      Open `apps/#{config.app}/test/support/factories.ex` and create an ExMachina test factory:

          def #{config.cases.target.single.snakecase_lower}_factory do
            %#{modulecase(config.app)}.#{config.cases.target.single.modulecase}{
              # add fields here...
            }
          end

      Then add in the fields, using the source resource as an example.
    """)
  end

  defp execute_step("Schema Tests", config) do
    root_directory = "apps/#{config.app}/test/#{config.app}/schemas"
    source_directory = "#{root_directory}/#{config.cases.source.single.snakecase_lower}_test.exs"
    target_directory = "#{root_directory}/#{config.cases.target.single.snakecase_lower}_test.exs"

    copy("#{source_directory}", "#{target_directory}")

    execute_with_all_cases(config, fn source, target ->
      replace("#{target_directory}", source, target)
    end)
  end

  defp execute_step("Contexts", config) do
    root_directory = "apps/#{config.app}/lib/#{config.app}/contexts"
    source_directory = "#{root_directory}/#{config.cases.source.single.snakecase_lower}"
    target_directory = "#{root_directory}/#{config.cases.target.single.snakecase_lower}"

    copy("#{source_directory}", "#{target_directory}")

    rename(target_directory, config.cases.source.plural.snakecase_lower, config.cases.target.plural.snakecase_lower)
    rename(target_directory, config.cases.source.single.snakecase_lower, config.cases.target.single.snakecase_lower)

    execute_with_all_cases(config, fn source, target ->
      replace("#{target_directory}", source, target)
    end)
  end

  defp execute_step("Context Tests", config) do
    root_directory = "apps/#{config.app}/test/#{config.app}/contexts"
    source_directory = "#{root_directory}/#{config.cases.source.single.snakecase_lower}"
    target_directory = "#{root_directory}/#{config.cases.target.single.snakecase_lower}"

    copy("#{source_directory}", "#{target_directory}")

    rename(target_directory, config.cases.source.plural.snakecase_lower, config.cases.target.plural.snakecase_lower)
    rename(target_directory, config.cases.source.single.snakecase_lower, config.cases.target.single.snakecase_lower)

    execute_with_all_cases(config, fn source, target ->
      replace("#{target_directory}", source, target)
    end)
  end

  defp execute_step("Permissions", config) do
    root =
      case config.app do
        "artemis" -> config.cases.target.plural.dashcase
        "artemis_log" -> config.cases.target.plural.dashcase
        _ -> "#{dashcase(config.app)}-#{config.cases.target.plural.dashcase}"
      end

    line_break()
    action("Create permissions")
    line_break()

    print("""
      Open `apps/artemis/lib/artemis/repo/generate_data.ex`, which is used to
      seed data into the database. Any changes here are added when the
      application is redeployed.

      Find the permissions section and create the resource permissions:

          %{slug: "#{root}:create", name: "#{config.cases.target.plural.spacecase} - Create"},
          %{slug: "#{root}:delete", name: "#{config.cases.target.plural.spacecase} - Delete"},
          %{slug: "#{root}:list", name: "#{config.cases.target.plural.spacecase} - List"},
          %{slug: "#{root}:show", name: "#{config.cases.target.plural.spacecase} - Show"},
          %{slug: "#{root}:update", name: "#{config.cases.target.plural.spacecase} - Update"},
    """)

    line_break()
    action("Add permissions to roles")
    line_break()

    print("""
      In the same `apps/artemis/lib/artemis/repo/generate_data.ex` file, find
      the section where permissions are added to roles.

      Add the permissions, commenting out as appropriate:

          "#{root}:create",
          "#{root}:delete",
          "#{root}:list",
          "#{root}:show",
          "#{root}:update",
    """)

    line_break()
    action("Update local development database")
    line_break()

    print("""
      Update the local development database with the latest permissions. From
      the command line execute:

          $ mix run apps/artemis/priv/repo/seeds.exs
    """)
  end

  defp execute_step("Routes", config) do
    root =
      case config.app do
        "artemis" -> config.cases.target.plural.dashcase
        "artemis_log" -> config.cases.target.plural.dashcase
        _ -> "#{dashcase(config.app)}-#{config.cases.target.plural.dashcase}"
      end

    controller =
      case config.app do
        "artemis" -> "#{config.cases.target.single.modulecase}Controller"
        "artemis_log" -> "#{config.cases.target.single.modulecase}Controller"
        _ -> "#{modulecase(config.app)}#{config.cases.target.single.modulecase}Controller"
      end

    line_break()
    action("Create routes")
    line_break()

    print("""
      Open the phoenix router `apps/#{config.app_web}/lib/#{config.app_web}/router.ex`,
      and add a new entry:

          # #{config.cases.target.single.spacecase}

          post "/#{root}/bulk-actions", #{controller}, :index_bulk_actions
          get "/#{root}/event-logs", #{controller}, :index_event_log_list
          get "/#{root}/event-logs/:id", #{controller}, :index_event_log_details

          resources "/#{root}", #{controller} do
            get "/event-logs", #{controller}, :show_event_log_list, as: :event_log
            get "/event-logs/:id", #{controller}, :show_event_log_details, as: :event_log
          end

      Note: depending on the resource the actual routes may be different. Use the
      source resource as a reference.
    """)
  end

  defp execute_step("Controller", config) do
    root_directory = "apps/#{config.app_web}/lib/#{config.app_web}/controllers"
    source_directory = "#{root_directory}/#{config.cases.source.single.snakecase_lower}_controller.ex"
    target_directory = "#{root_directory}/#{config.cases.target.single.snakecase_lower}_controller.ex"

    copy("#{source_directory}", "#{target_directory}")

    execute_with_all_cases(config, fn source, target ->
      replace("#{target_directory}", source, target)
    end)
  end

  defp execute_step("View", config) do
    root_directory = "apps/#{config.app_web}/lib/#{config.app_web}/views"
    source_directory = "#{root_directory}/#{config.cases.source.single.snakecase_lower}_view.ex"
    target_directory = "#{root_directory}/#{config.cases.target.single.snakecase_lower}_view.ex"

    copy("#{source_directory}", "#{target_directory}")

    execute_with_all_cases(config, fn source, target ->
      replace("#{target_directory}", source, target)
    end)
  end

  defp execute_step("Templates", config) do
    root_directory = "apps/#{config.app_web}/lib/#{config.app_web}/templates"
    source_directory = "#{root_directory}/#{config.cases.source.single.snakecase_lower}"
    target_directory = "#{root_directory}/#{config.cases.target.single.snakecase_lower}"

    copy("#{source_directory}/", "#{target_directory}/")

    rename(target_directory, config.cases.source.plural.snakecase_lower, config.cases.target.plural.snakecase_lower)
    rename(target_directory, config.cases.source.single.snakecase_lower, config.cases.target.single.snakecase_lower)

    execute_with_all_cases(config, fn source, target ->
      replace("#{target_directory}/*", source, target)
    end)
  end

  defp execute_step("Controller Tests", config) do
    root_directory = "apps/#{config.app_web}/test/#{config.app_web}/controllers"
    source_directory = "#{root_directory}/#{config.cases.source.single.snakecase_lower}_controller_test.ex"
    target_directory = "#{root_directory}/#{config.cases.target.single.snakecase_lower}_controller_test.ex"

    copy("#{source_directory}", "#{target_directory}")

    rename(target_directory, config.cases.source.plural.snakecase_lower, config.cases.target.plural.snakecase_lower)
    rename(target_directory, config.cases.source.single.snakecase_lower, config.cases.target.single.snakecase_lower)

    execute_with_all_cases(config, fn source, target ->
      replace("#{target_directory}", source, target)
    end)
  end

  defp execute_step("Browser Tests", config) do
    root_directory = "apps/#{config.app_web}/test/#{config.app_web}/browser"
    source_directory = "#{root_directory}/#{config.cases.source.single.snakecase_lower}_page_test.ex"
    target_directory = "#{root_directory}/#{config.cases.target.single.snakecase_lower}_page_test.ex"

    copy("#{source_directory}", "#{target_directory}")

    execute_with_all_cases(config, fn source, target ->
      replace("#{target_directory}", source, target)
    end)
  end

  defp execute_step("Navigation", config) do
    key =
      case String.contains?(config.cases.target.single.spacecase, " ") do
        true -> "\"#{config.cases.target.single.spacecase}\""
        false -> config.cases.target.single.spacecase
      end

    line_break()
    action("Add to navigation")
    line_break()

    print("""
      Open the navigation config `apps/#{config.app_web}/lib/#{config.app_web}/config/navigation.ex`,
      and add a new entry:

          #{key}: [
            [
              label: "List #{config.cases.target.plural.spacecase}",
              path: &Routes.#{config.cases.target.single.snakecase_lower}_path(&1, :index),
              verify: &has?(&1, "#{config.cases.target.plural.dashcase}:list")
            ],
            [
              label: "Create New #{config.cases.target.single.spacecase}",
              path: &Routes.#{config.cases.target.single.snakecase_lower}_path(&1, :new),
              verify: &has?(&1, "#{config.cases.target.plural.dashcase}:create")
            ]
          ],

      Note: depending on the resource the actual navigation items may differ. Use the
      source resource as a reference.
    """)
  end

  defp execute_step(step, _config) do
    print("#{step} step is not implemented yet")
  end
end
