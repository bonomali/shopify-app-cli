require 'test_helper'

module ShopifyCli
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
        @command = ShopifyCli::Commands::Create.new(@context)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Create.help)
        @command.call([], nil)
      end

      def test_with_project_calls_project
        ShopifyCli::Commands::Create::Project.any_instance.expects(:call)
          .with(['project', 'new-app'], 'project')
        ShopifyCli::EntryPoint.call(['create', 'project', 'new-app'])
      end
    end
  end
end
