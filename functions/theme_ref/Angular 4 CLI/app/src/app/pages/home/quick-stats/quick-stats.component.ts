import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'quick-stats',
  templateUrl: './quick-stats.component.html',
  styleUrls: ['./quick-stats.component.scss']
})

export class QuickStatsComponent implements OnInit {
  quickStatChartOptions:any; // Quick Stats Chart Options
  quickStatChartData:any; // Quick Stats Chart Data

  constructor() {
    this.quickStatChartData = [
      {
        title: 'Website Traffics',
        value: '987,459',
        data: [6,4,8,6,5,6,7,8,3,5,9,5],
        color: 'light-blue'
      },
      {
        title: 'Website Impressions',
        value: '356,785K',
        data: [4,7,6,2,5,3,8,6,6,4,8,6],
        color: 'amber'
      },
      {
        title: 'Total Sales',
        value: '$ 458,778',
        data: [9,4,6,5,6,4,5,7,9,3,6,5],
        color: 'purple'
      },
      {
        title: 'Support Tickets',
        value: '201',
        data: [5,6,3,9,7,5,4,6,5,6,4,9],
        color: 'red'
      }
    ];

    this.quickStatChartOptions = {
      type: 'bar',
      height: '36px',
      barWidth: 3,
      barColor: 'rgba(255,255,255,0.8)',
      barSpacing: 2
    }
  }

  ngOnInit() {
  }

}
