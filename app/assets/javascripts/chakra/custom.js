$(function() {
	$(".full-calendar").each(function() {
		var url = $(this).attr("data-calendar-url")
		$(this).fullCalendar(
		{
			events: url, 
			titleFormat: {
				month: "MMMM"
			},
      dayNames: ['Sunnuntai', 'Maanantai', 'Tiistai', 'Keskiviikko',
 'Torstai', 'Perjantai', 'Lauantai'],
      monthNames: ['tammikuu', 'helmikuu', 'maaliskuu', 'huhtikuu', 'toukokuu', 'kesäkuu', 'heinäkuu',
 'elokuu', 'syyskuu', 'lokakuu', 'marraskuu', 'joulukuu'],
      timeFormat: '',
      eventRender: function(event, element) {
        event
      }
		});
	})
});