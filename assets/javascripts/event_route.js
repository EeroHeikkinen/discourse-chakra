(function() {
  /*
  function namedCategory(category, options) {
    if(category.name == Discourse.SiteSettings["projects_category"])
      return "projects";
    if(category.name == Discourse.SiteSettings["events_category"])
      return "events";
    if(category.name == Discourse.SiteSettings["blogposts_category"])
      return "blog";
  }
  function namedCategoryLink(category, options) {
    var name = namedCategory(category, options);
    if(!name)
      return;
    
    return new Handlebars.SafeString('<a href="//' + Discourse.BaseUrl + '/' + name +'" class="chakra-link">' + I18n.t(name) + '</a>');
  }

  Ember.Handlebars.registerHelper('namedCategoryLink', namedCategoryLink);
  Ember.Handlebars.registerHelper('namedCategory', namedCategory);
  */

  Discourse.Route.buildRoutes(function() {
    this.route('event', {path: '/create_event/:date'});
    this.route('idea', {path: '/create_idea'})
  });

  function openPrefilledComposer(title, content, category_slug, draftKey) {
    var route = this;
    var category = Discourse.Category.findBySlug(category_slug);
    if(!category) {
        bootbox.alert("Category " + category_slug + " needs to be created.");
    }

    // Needs to be set to get a working URL?
    category.parentSlug = category_slug;

    var user = route.controllerFor("discoveryTopics").get("currentUser");
    if(!user) {
      bootbox.alert("You need to sign up or login first.");
      route.transitionTo("login")
      return;
    }

    route.transitionTo('discovery.latestCategoryNone', category).then(function(e) {
      Ember.run.next(function() {
        var composer = route.controllerFor('composer');

        composer.open({
          action: Discourse.Composer.CREATE_TOPIC,
          categoryId: category.id,
          draftKey: draftKey,
          title: title
        }).then(function(result) {
          if(!composer.get("model.reply")) {
            composer.appendText(content);
          }
        });
      });
    });
  }

  Discourse.EventRoute = Discourse.Route.extend({
    beforeModel: function(model) {
      var date = model.params.date;

      openPrefilledComposer.call(this,
        I18n.t("event_placeholder_title"),
        I18n.t("event_template", date? {date: date}: {}),
        Discourse.SiteSettings["events_category"],
        "new_event" + date ? date : ''
      );
    }
  })

  Discourse.IdeaRoute = Discourse.Route.extend({
    beforeModel: function(model) {
      openPrefilledComposer.call(this,
        I18n.t("idea_placeholder_title"),
        I18n.t("idea_template"),
        Discourse.SiteSettings["ideas_category"],
        "new_idea"
      );
    }
  })

})();