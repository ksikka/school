// @ksikka

var PathModel = Backbone.Model.extend({
  initialize: function() {
    // initialize to root
    this.set('path', ['_root']);
    this.set('childCats', []);
    this.fetchCats();
  },
  fetchCats: function() {
    // get the subcategories of this path from the server.
    var path = this.get('path');
    var cat = path[path.length - 1];
    $.get('/getSubCats.php', {cat: cat}, function(d) {
      // expect d to be an array of strings.
      this.set('childCats', d);
      this.trigger('changeCats');
    }.bind(this));
  },
  goDeeper: function(catName) {
    var path = this.get('path');
    path.push(catName);
    this.set('path', path);
    this.trigger('changePath');
    this.fetchCats();
  },
  goBack: function() {
    var path = this.get('path');
    if (path.length > 1) {
      path.pop();
      this.set('path', path);
      this.trigger('changePath');
      this.fetchCats();
    }
  },
  goToIndex: function(i) {
    var path = this.get('path');
    if (path[i]) {
      path = path.slice(0, i+1);
      this.set('path', path);
      this.trigger('changePath');
      this.fetchCats();
    }
  },

});

var UrlView = Backbone.View.extend({
  events: {
    'click .breadcrumb': 'clickBread',
    'click .backBtn': 'goback'
  },
  initialize: function() {
    this.listenTo(this.model, 'changePath', this.render);
  },
  render: function() {
    this.el.innerHTML='';
    var path = this.model.get('path');
    this.$el.append('<span class="backBtn clickable">&lt;-</span><span class="bar"></span>');
    _.each(path, function(p, i) {
      this.$el.find('.bar').append('<span class="spacer">/</span><span class="clickable breadcrumb" data-index="' + i + '">' + p + '</span>')
    }, this);
  },
  clickBread: function(e) {
    var catName = $(e.target).data('index');
    this.model.goToIndex(catName);
  },
  goback: function(e) {
    this.model.goBack();
  },
});

var CatChildView = Backbone.View.extend({
  events: {
    'click .category': 'clickCat'
  },
  initialize: function() {
    this.listenTo(this.model, 'changeCats', this.render);
  },
  render: function() {
    this.el.innerHTML='';
    var cats = this.model.get('childCats');
    if (cats.length === 0) {
      this.$el.append('<p>No subcategories, you reached a leaf.</p>');
    } else {
      _.each(cats, function(c) {
        this.$el.append('<div class="clickable category">' + c + '</div>');
      }, this);
    }
  },
  clickCat: function(e) {
    var catName = $(e.target).text();
    this.model.goDeeper(catName);
  }
});


$('document').ready(function() {
  $('body').prepend(['<div id="category-picker">',
                     '<h2>Category Browser</h2>',
                     '<p>By ksikka. Written using jQuery, Underscore, and Backbone.js.</p>',
                     '<ul>',
                     '<li>Click the Categories to see their children.</li>',
                     '<li>Click Inanimate -> Sports etc to see a 3 level deep traversal.</li>',
                     '<li>Click the / separated links to skip around.</li>',
                     '<li>Click the back button next to the / separated path to go up a level.</li>',
                     '</ul>',
                     '<div id="catpickerwrapper">',
                       '<div id="urlview"></div>',
                       '<div id="catchildview"></div>',
                     '</div>',
                     '</div>',
                     ].join('\n'));
  p = new PathModel();
  var urlv = new UrlView({ el: $('#urlview'), model: p });
  var catchildv = new CatChildView({ el: $('#catchildview'), model: p });
  urlv.render();
  catchildv.render();

});
