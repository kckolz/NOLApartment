var App = { Models: {}, Views: {}, Collections: {}, Data: {} };

App.Models.ApartmentSearch = Backbone.Model.extend({
  priceDisplay: function() {
    return '$' + this.get('minPrice') + '-' + '$' + this.get('maxPrice');
  },
  bedsDisplay: function() {
    return this.get('minBeds') + '-' + this.get('maxBeds');
  },
  daysDisplay: function() {
    return this.get('daysOld') + ' days';
  }
});

App.Models.Apartment = Backbone.Model.extend({
  daysSincePosted: function() {
    return Math.floor((new Date() - new Date(this.get('published'))) / (1000*60*60*24));
  }
});

App.Collections.Apartments = Backbone.Collection.extend({
  model: App.Models.Apartment,
  url: '/apartments',
  search: function(search) {
    return this.filter(function(apartment) {
      var priceMatch = apartment.get('price') >= search.get('minPrice') && apartment.get('price') <= search.get('maxPrice'),
        bedMatch = apartment.get('beds') >= search.get('minBeds') && apartment.get('beds') <= search.get('maxBeds');
        dayMatch = apartment.daysSincePosted() <= search.get('daysOld');

        return priceMatch && bedMatch && dayMatch;
    });
  }
});

App.Views.Slider = Backbone.View.extend({
  tagName: 'fieldset',
  template: Handlebars.compile($('#slider-template').html()),
  initialize: function() {
    var $element = this.$el,
      search = this.model,
      displayAttr = this.displayAttribute;

    var sliderOptions = {
      range: false,
      min: this.sliderMin,
      max: this.sliderMax,
      step: this.sliderStep
    };

    if (this.values.length == 2) {
      var minAttr = this.values[0],
        maxAttr = this.values[1];

      sliderOptions.range = true;
      sliderOptions.values = [search.get(minAttr), search.get(maxAttr)]
      sliderOptions.slide = function(event, ui) {
        search.set(minAttr, ui.values[0]);
        search.set(maxAttr, ui.values[1]);
        $element.find('.value').html(search[displayAttr]());
      }
    }
    else {
      var attribute = this.values[0];

      sliderOptions.value = search.get(attribute);
      sliderOptions.slide = function(event, ui) {
        search.set(attribute, ui.value)
        $element.find('.value').html(search[displayAttr]());
      }
    }

    this.render();

    this.$el.find('.slider').slider(sliderOptions);
  },
  render: function() {
    this.$el.html(this.template({
      label: this.label,
      value: this.model[this.displayAttribute]()
    }));
  }
});

App.Views.Map = Backbone.View.extend({
  apartmentTemplate: Handlebars.compile($('#apartment-template').html()),
  initialize: function() {
    this.collection = new App.Collections.Apartments(App.Data.apartments);
    this.markers = [];

    mapOptions = {
      center: new google.maps.LatLng(29.9728, -90.05902),
      zoom: 13,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    this.render();
    this.map = new google.maps.Map(this.$el[0], mapOptions);
    this.mapApartments();


    this.model.on('change', this.mapApartments, this);
  },
  render: function() {
    return self;
  },
  mapApartments: function() {
    this.clearMap();

    var markerTemplate = this.apartmentTemplate,
      gMap = this.map;

    this.markers = this.collection.search(this.model).map(function(apartment) {
      var marker = new google.maps.Marker({
        position: new google.maps.LatLng(apartment.get('latitude'), apartment.get('longitude')),
        html: markerTemplate(apartment)
      });

      marker.setMap(gMap);

      infoWindow = new google.maps.InfoWindow()

      google.maps.event.addListener(marker, 'click', function() {
        infoWindow.setContent(this.html);
        infoWindow.open(map, this);
      });

      return marker;
    });

  },
  clearMap: function() {
    _.each(this.markers, function(marker) {
      marker.setMap(null);
    });

    this.markers = [];
  }
});

App.Views.PriceSlider = App.Views.Slider.extend({
  label: 'Price',
  values: ['minPrice', 'maxPrice'],
  displayAttribute: 'priceDisplay',
  sliderMin: 0,
  sliderMax: 5000,
  sliderStep: 50
});

App.Views.BedSlider = App.Views.Slider.extend({
  label: 'Beds',
  values: ['minBeds', 'maxBeds'],
  displayAttribute: 'bedsDisplay',
  sliderMin: 0,
  sliderMax: 10,
  sliderStep: 1
});

App.Views.DaySlider = App.Views.Slider.extend({
  label: 'Posted in the last',
  values: ['daysOld'],
  displayAttribute: 'daysDisplay',
  sliderMin: 0,
  sliderMax: 7,
  sliderStep: 1
});


var search = new App.Models.ApartmentSearch({
  minPrice: 500,
  maxPrice: 2500,
  minBeds: 0,
  maxBeds: 10,
  daysOld: 7
});
