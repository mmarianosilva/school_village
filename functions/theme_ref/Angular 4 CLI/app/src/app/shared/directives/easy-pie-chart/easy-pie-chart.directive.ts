import { Directive, Input, ElementRef } from '@angular/core';
declare var jQuery: any;

@Directive({
  selector: '[EasyPieChart]'
})

export class EasyPieChartDirective {
  @Input() private size:any;

  constructor(private el: ElementRef) { }

  ngOnInit() {
    let initEasyPieChart = jQuery(this.el.nativeElement);

    initEasyPieChart.find('.easy-pie-chart__value').css({
      lineHeight: (this.size)+'px',
      fontSize: (this.size/4)+'px'
    });

    initEasyPieChart.easyPieChart({
      easing: 'easeOutBounce',
      barColor: '#fff',
      trackColor: 'rgba(0,0,0,0.08)',
      scaleColor: 'rgba(0,0,0,0)',
      lineCap: 'round',
      lineWidth: 2,
      size: this.size,
      animate: 3000
    });
  }
}
