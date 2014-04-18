Discourse.TopicController.reopen({
  actions: {
    joinProject: function(){
      window.location.href = "//" + Discourse.BaseUrl + "/join_project/" + this.content.id;
    },
    leaveProject: function(){
      window.location.href = "//" + Discourse.BaseUrl + "/leave_project/" + this.content.id;
    }
  }
})

Discourse.ParticipantsView = Discourse.View.extend({
    templateName: "project_participants",
    attributeBindings: ["model"], //, "editingTopic"],

    //editingTopic: Em.computed.alias('controller.editingTopic'),

    insertParticipantsView: function() {
        var view = this;
        if (view.state === "inDOM") return;

        Ember.run.schedule('afterRender', this, function(){
            var target = view._parentView.$("h1").parent();
            if (target.length) {
                if (view.state === "preRender") view.createElement();
                target.append(view.$());
            }
        });
    }/*,
    editingChanged: function(){
      this.rerender();
    }.observes("editingTopic")*/
});

/*Discourse.TopicController.reopen({
  
  actions: {
    removeTag: function(toRm){
      this.get("new_tags").removeObject(toRm.toString());
    }
  },

  editTags: function(){
    if (!this.get("editingTopic")) var new_tags = null;
    else new_tags = this.get("tags").copy();
    this.set("new_tags", new_tags)
  }.observes("editingTopic"),

  saveTags: function(){
    if (!this.get("topicSaving")) return;
    // implicit is good enough for us here
    var topic = this.get("model"),
        tags = this.get("new_tags"); // we do total inline edit here
    Discourse.ajax('/tagger/set_tags', {
                        data: {
                          tags: tags.join(","),
                          topic_id: topic.get("id")
                        }
                      })
        .then(function(tag_res) {
          topic.get("tags").setObjects(tag_res.tags);
        });
  }.observes('topicSaving'),
})*/

Discourse.TopicView.reopen({
    insertParticipantsView: function() {
        if (this.get("participantsview")) return;

        var view = this.createChildView(Discourse.ParticipantsView,
                        {controller: this.get("controller")});
        view.insertParticipantsView();
        this.set("participantsview", view)
    }.on("didInsertElement"),

    ensureParticipants: function(){
        if (!this.get("participantsview")) return;
        this.get("participantsview").insertParticipantsView();
    }.observes(
      //'topic.tags', 
      'topic.loaded'),

    removeParticipants: function(){
        if (this.get("participantsview")){
            this.get("participantsview").destroy();
            this.set("participantsview", null);
        }
    }.on("willClearRender"),

    killParticipants: function(){
        if (this.get("participantsview")){
            this.get("participantsview").destroy();
            this.set("participantsview", null);
        }
    }.on("willDestroyElement")
});