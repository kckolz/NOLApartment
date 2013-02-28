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
  initialize: function() {
    this.set('daysSincePosted',this.getDaysSincePosted());
  },
  getDaysSincePosted: function() {
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
        dayMatch = apartment.get('daysSincePosted') <= search.get('daysOld');

        return priceMatch && bedMatch && dayMatch;
    });
  }
});

App.Views.Slider = Backbone.View.extend({
  tagName: 'fieldset',
  template: Handlebars.compile($('#slider-template').html()),
  initialize: function() {
    this.listenTo(this.model, 'change', this.setDisplay);
    this.render();

    this.$el.find('.slider').slider(this.getSliderOptions());
  },
  getSliderOptions: function() {
    var attribute = this.value,
      self = this;

    var sliderOptions = {
      range: false,
      min: this.sliderMin,
      max: this.sliderMax,
      step: this.sliderStep,
      value: this.model.get(attribute),
      slide: function(event, ui) {
        self.model.set(attribute, ui.value);
      },
      change: function(event, ui) {
        self.model.trigger('change_complete');
      }
    };

    return sliderOptions;
  },
  setDisplay: function() {
    this.$el.find('.value').html(this.model[this.displayAttribute]());
  },
  render: function() {
    this.$el.html(this.template({
      label: this.label
    }));

    this.setDisplay();
  }
});


App.Views.RangeSlider = App.Views.Slider.extend({
  getSliderOptions: function() {
    var minAttr = this.values[0],
      maxAttr = this.values[1],
      setDisplay = this.setDisplay,
      self = this;

    var sliderOptions = {
      range: true,
      min: this.sliderMin,
      max: this.sliderMax,
      step: this.sliderStep,
      values: [this.model.get(minAttr), this.model.get(maxAttr)],
      slide: function(event, ui) {
        self.model.set(minAttr, ui.values[0]);
        self.model.set(maxAttr, ui.values[1]);
      },
      change: function(event, ui) {
        self.model.trigger('change_complete');
      }
    };

    return sliderOptions;
  }
});

App.Views.Map = Backbone.View.extend({
  apartmentTemplate: Handlebars.compile($('#apartment-template').html()),
  initialize: function(options) {
    this.collection = new App.Collections.Apartments(App.Data.apartments);
    this.markers = [];
    this.avgPerBed = options.avgPerBed;

    mapOptions = {
      center: new google.maps.LatLng(29.9728, -90.05902),
      zoom: 13,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    this.render();
    this.map = new google.maps.Map(this.$el[0], mapOptions);
    this.mapApartments();


    this.listenTo(this.model, 'change_complete', this.mapApartments, this);
  },
  render: function() {
    return self;
  },
  mapApartments: function() {
    this.clearMap();

    var markerTemplate = this.apartmentTemplate,
      gMap = this.map,
      calcPriceClass = _.bind(this.calcPriceClass, this);

    this.markers = this.collection.search(this.model).map(function(apartment) {
      var templateData = apartment.toJSON();
      templateData.priceClass = calcPriceClass(apartment);

      var marker = new google.maps.Marker({
        position: new google.maps.LatLng(apartment.get('latitude'), apartment.get('longitude')),
        html: markerTemplate(templateData)
      });

      marker.setMap(gMap);

      infoWindow = new google.maps.InfoWindow()

      google.maps.event.addListener(marker, 'click', function() {
        infoWindow.setContent(this.html);
        infoWindow.open(gMap, marker);
      });

      return marker;
    });

  },
  clearMap: function() {
    _.each(this.markers, function(marker) {
      marker.setMap(null);
    });

    this.markers = [];
  },
  calcPriceClass: function(apartment) {
    var price = apartment.get('price'),
      beds = apartment.get('beds'),
      klass;

    if (this.avgPerBed && price && beds) {

      var diff = (price / beds) / this.avgPerBed;

      if (diff >= 1.1) {
        klass = 'high-price';
      }
      else if (diff <= 0.9) {
        klass = 'low-price';
      }
    }

    return klass;
  }
});

App.Views.PriceSlider = App.Views.RangeSlider.extend({
  label: 'Price',
  values: ['minPrice', 'maxPrice'],
  displayAttribute: 'priceDisplay',
  sliderMin: 0,
  sliderMax: 5000,
  sliderStep: 50
});

App.Views.BedSlider = App.Views.RangeSlider.extend({
  label: 'Beds',
  values: ['minBeds', 'maxBeds'],
  displayAttribute: 'bedsDisplay',
  sliderMin: 0,
  sliderMax: 10,
  sliderStep: 1
});

App.Views.DaySlider = App.Views.Slider.extend({
  label: 'Posted in the last',
  value: 'daysOld',
  displayAttribute: 'daysDisplay',
  sliderMin: 0,
  sliderMax: 7,
  sliderStep: 1
});
