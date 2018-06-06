import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'widget-past-days',
  templateUrl: './past-days.component.html',
  styleUrls: ['./past-days.component.scss']
})

export class PastDaysComponent implements OnInit {
  pastDaysChartOptions:any; // Main Chart Options
  pastDaysChartData:any; // Main Chart Data
  pastDaysData:any; // Widget Data
  pastDaysSubChartDataOptions:any; // Widget Chart Data

  constructor() {
    this.pastDaysChartOptions = {
      series: {
        shadowSize: 0,
        curvedLines: {
          apply: true,
          active: true,
          monotonicFit: true
        },
        lines: {
          show: false,
          lineWidth: 0
        }
      },
      grid: {
        borderWidth: 0,
        labelMargin:10,
        hoverable: true,
        clickable: true,
        mouseActiveRadius:6

      },
      xaxis: {
        tickDecimals: 0,
        ticks: false
      },

      yaxis: {
        tickDecimals: 0,
        ticks: false
      },

      legend: {
        show: false
      }
    };

    this.pastDaysChartData = [{
      label: 'Product 1',
      stack: true,
      color: '#35424b',
      lines: {
        show: true,
        fill: 1,
        fillColor: {
          colors: ['rgba(255,255,255,0)', 'rgba(255,255,255,0.6)']
        }
      },
      data:  [[1,3], [2,9], [3,8], [4,6], [5,11], [6,4], [7,7]]
    }];

    this.pastDaysData = [
      {
        title: 'Page Views',
        value: '47,896,536',
        chartData: [6,9,5,6,3,7,5,4,6,5,6,4,2,5,8,2,6,9]
      },
      {
        title: 'Site Visitors',
        value: '24,456,799',
        chartData: [5,7,2,5,2,8,6,7,6,5,3,1,9,3,5,8,2,4]
      },
      {
        title: 'Total Clicks',
        value: '13,965',
        chartData: [5,7,2,5,2,8,6,7,6,5,3,1,9,3,5,8,2,4]
      },
      {
        title: 'Total Returns',
        value: '198',
        chartData: [3,9,1,3,5,6,7,6,8,2,5,2,7,5,6,7,6,8]
      },
    ];

    this.pastDaysSubChartDataOptions = {
      type: 'bar',
      height: '36px',
      barWidth: 3,
      barColor: '#fff',
      barSpacing: 2
    }
  }

  ngOnInit() {

  }
}
