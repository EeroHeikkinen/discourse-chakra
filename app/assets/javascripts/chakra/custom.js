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
      dayNamesShort: ['Su', 'Ma', 'Ti', 'Ke', 'To', 'Pe', 'La'],
      monthNames: ['tammikuu', 'helmikuu', 'maaliskuu', 'huhtikuu', 'toukokuu', 'kesäkuu', 'heinäkuu',
 'elokuu', 'syyskuu', 'lokakuu', 'marraskuu', 'joulukuu'],
      timeFormat: '',
      firstDay: 1,
      eventRender: function(event, element) {
        var url = event.description;
        if(!url) return;
        $(element).first("a").attr("href", url)
      },
      selectable: true,
      selectHelper: true,
      select: function(start, end, allDay) {
        var title = prompt('Event Title:');
        if (title) {
          calendar.fullCalendar('renderEvent',
            {
              title: title,
              start: start,
              end: end,
              allDay: allDay
            },
            true // make the event "stick"
          );
        }
        calendar.fullCalendar('unselect');
      },
      buttonText: {
        prev:     '&lsaquo;', // <
        next:     '&rsaquo;', // >
        prevYear: '&laquo;',  // <<
        nextYear: '&raquo;',  // >>
        today:    'tänään',
        month:    'kuukausi',
        week:     'viikko',
        day:      'päivä'
      }
		});
	})
});