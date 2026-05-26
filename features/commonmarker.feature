Feature: Markdown (Commonmarker) support
  In order to render Markdown with commonmarker via the middleman-commonmarker extension

  Scenario: Commonmarker basic rendering
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      activate :commonmarker
      """
    Given the Server is running at "markdown-app"
    When I go to "/index.html"
    Then I should see "<p>"

  Scenario: Commonmarker smartypants extension
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      activate :commonmarker
      set :markdown, smartypants: true
      """
    Given the Server is running at "markdown-app"
    When I go to "/smarty_pants.html"
    Then I should see "“Hello”"

  Scenario: Commonmarker fenced code blocks
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      activate :commonmarker
      """
    Given the Server is running at "markdown-app"
    When I go to "/fenced_code_blocks.html"
    Then I should see "<code>"

  Scenario: Commonmarker table extension
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      activate :commonmarker
      set :markdown, table: true
      """
    Given the Server is running at "markdown-app"
    When I go to "/tables.html"
    Then I should see "<table>"

  Scenario: Commonmarker strikethrough extension
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      activate :commonmarker
      set :markdown, strikethrough: true
      """
    Given the Server is running at "markdown-app"
    When I go to "/strikethrough.html"
    Then I should see "<del>"

  Scenario: Commonmarker autolink extension
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      activate :commonmarker
      set :markdown, autolink: true
      """
    Given the Server is running at "markdown-app"
    When I go to "/autolink.html"
    Then I should see "<a href"

  Scenario: Commonmarker passes options through activate
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      activate :commonmarker, options: { table: true }
      """
    Given the Server is running at "markdown-app"
    When I go to "/tables.html"
    Then I should see "<table>"

  Scenario: Commonmarker uses our link_to and image_tag helpers
    Given a fixture app "markdown-app"
    And a file named "config.rb" with:
      """
      activate :commonmarker
      activate :automatic_image_sizes
      activate :directory_indexes
      """
    And a file named "source/link_and_image.html.markdown" with:
      """
      [A link](/smarty_pants.html)

      ![image](blank.gif)
      """
    Given the Server is running at "markdown-app"
    When I go to "/link_and_image/"
    Then I should see "/smarty_pants/"
    Then I should see 'width="1"'
    And I should see 'height="1"'
    And I should see 'src="/images/blank.gif"'
