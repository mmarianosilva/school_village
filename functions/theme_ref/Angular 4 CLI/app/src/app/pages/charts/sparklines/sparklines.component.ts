import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-sparklines',
  templateUrl: './sparklines.component.html',
  styleUrls: ['./sparklines.component.scss']
})
export class SparklinesComponent implements OnInit {
  sparklineBarData: Array<any> = [6,9,5,6,3,7,5,4,6,5,6,4,2,5,8,2,6,9,5,7,2,5,2,8,6,7,6,5,3,1,9,3,5,8,2,4];
  sparklineTristateData: Array<any> = [1,1,0,1,-1,-1,1,-1,0,0,1,1,-1,0,0,0,0,-1,1,1,1,-1,1-1,1,-1,0,0,1,1,-1,-1,1,-1,0,0,1,1];
  sparklineDiscreteData: Array<any> = [4,6,7,7,4,3,2,1,4,4,5,7,1,9,5,3,6,3,1,0,8,4,3,5,1,5,7,4,4,4,1,2,4,7,1,9,5,3,6,3,1,0,8,4,3,5,9,9,9,9,9,4,1,1,1,4,2,4,3,7,6,8,9,6,4,6,4,3,6,3,7,2,3];
  sparklineBulletData: Array<any> = [10,12,12,9,7];
  sparklineLineData: Array<any> = [9,5,6,3,9,7,5,4,6,5,6,4,9];
  sparklinePieData: any = {
    1: [1,1,2],
    2: [1,1,1],
    3: [1,3,1,1]
  };

  sparklineBarOptions: any = {
    type: 'bar',
    height: 40,
    barWidth: 3,
    barColor: '#03A9F4',
    barSpacing: 2
  };

  sparklineTristateOptions: any = {
    type: 'tristate',
    height: 40,
    posBarColor: '#32c787',
    zeroBarColor: '#32c787',
    negBarColor: '#f5c942',
    barWidth: 3,
    barSpacing: 2
  };

  sparklineDiscreteOptions: any = {
    type: 'discrete',
    height: 40,
    lineColor: '#00BCD4',
    thresholdColor: '#d066e2',
    thresholdValue: 4
  };

  sparklineBulletOptions: any = {
    type: 'bullet',
    targetColor: '#fff',
    performanceColor: '#03A9F4',
    rangeColors: ['#ff6b68', '#fc7f7d', '#fc918f'],
    width: '100%',
    height: 50
  };

  sparklineLineOptions: any = {
    type: 'line',
    width: '100%',
    height: 50,
    lineColor: '#fea6a4',
    fillColor: 'rgba(0,0,0,0)',
    lineWidth: 1,
    maxSpotColor: '#ff6b68',
    minSpotColor: '#ff6b68',
    spotColor: '#ff6b68',
    spotRadius: 4,
    highlightSpotColor: '#ff6b68',
    highlightLineColor: '#ff6b68'
  };

  sparklinePieOptions: any = {
    type: 'pie',
    height: 50,
    sliceColors: ['#f5c942', '#ff6b68', '#03A9F4', '#32c787']
  };

  constructor() { }

  ngOnInit() {
  }

}
