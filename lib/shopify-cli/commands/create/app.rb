require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create
      class App < ShopifyCli::SubCommand
        options do |parser, flags|
          parser.on('--title=TITLE') { |t| title[:title] = t }
          parser.on('--type=TYPE') { |t| flags[:type] = t.downcase.to_sym }
          parser.on('--organization_id=ID') { |url| flags[:organization_id] = url }
          parser.on('--shop_domain=MYSHOPIFYDOMAIN') { |url| flags[:shop_domain] = url }
        end

        def call(args, _name)
          form = Forms::CreateApp.ask(@ctx, args, options.flags)
          return @ctx.puts(self.class.help) if form.nil?

          AppTypeRegistry.check_dependencies(form.type, @ctx)
          AppTypeRegistry.build(form.type, form.name, @ctx)
          ShopifyCli::Project.write(@ctx, :app, 'app_type' => form.type)

          api_client = Tasks::CreateApiClient.call(
            @ctx,
            org_id: form.organization_id,
            title: form.title,
            app_url: 'https://shopify.github.io/shopify-app-cli/getting-started',
          )

          Helpers::EnvFile.new(
            api_key: api_client["apiKey"],
            secret: api_client["apiSecretKeys"].first["secret"],
            shop: form.shop_domain,
            scopes: 'write_products,write_customers,write_draft_orders',
          ).write(@ctx)

          partners_url = "https://partners.shopify.com/#{form.organization_id}/apps/#{api_client['id']}"

          @ctx.puts("{{v}} {{green:#{form.title}}} was created in your Partner" \
                    " Dashboard " \
                    "{{underline:#{partners_url}}}")
          @ctx.puts("{{*}} Run {{cyan:shopify serve}} to start a local server")
          @ctx.puts("{{*}} Then, visit {{underline:#{partners_url}/test}} to install" \
                    " {{green:#{form.title}}} on your Dev Store")
        end

        def self.help
          <<~HELP
            Create a new app project.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} create app <appname>}}
          HELP
        end

        def self.extended_help
          <<~HELP
            {{bold:Subcommands:}}
              {{cyan:project}}: Creates an app based on type selected.
                Usage: {{command:#{ShopifyCli::TOOL_NAME} create project <appname>}}
                Options:
                  {{command:--type=TYPE}}  App project type. Valid types are "node" and "rails"
                  {{command:--title=TITLE}} App project title. Any string.
                  {{command:--app_url=APPURL}} App project URL. Must be valid URL.
                  {{command:--organization_id=ID}} App project Org ID. Must be existing org ID.
                  {{command:--shop_domain=MYSHOPIFYDOMAIN }} Test store URL. Must be existing test store.
              {{cyan:dev-store}}: {{yellow: Create dev-store is not currently available.}}
          HELP
        end
      end
    end
  end
end