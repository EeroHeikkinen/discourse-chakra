(function() {
  Discourse.Route.buildRoutes(function() {
    this.route('event', {path: '/create_event/:date'});
  });

  Discourse.EventRoute = Discourse.Route.extend({
    beforeModel: function(model) {
      var that = this;
      
      var events_slug = Discourse.SiteSettings["events_category"];
      var events_category = Discourse.Category.findBySlug(events_slug);
      events_category.parentSlug = "events"

      this.transitionTo('discovery.latestCategoryNone', events_category).then(function(e) {
        Ember.run.next(function() {
          var composer = that.controllerFor('composer');
          var date = model.params.date;
          if(!date) {
            bootbox.alert("No date specified");
            return;
          }
          
          var user = that.controllerFor("discoveryTopics").get("currentUser");
          if(!user) {
            bootbox.alert("You need to sign up or login to create an event.");
            return;
          }

          composer.open({
            action: Discourse.Composer.CREATE_TOPIC,
            categoryId: events_category.id,
            draftKey: "new_event" + date,
            title: I18n.t("event_placeholder_title")
          }).then(function(result) {
            if(!composer.get("model.reply")) {
              composer.appendText(I18n.t("event_template", {date: date}));
            }
          });
        });
      });
    }
  })

})();