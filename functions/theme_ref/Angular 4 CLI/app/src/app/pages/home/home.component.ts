import { Component, OnInit } from '@angular/core';

@Component({
    selector: 'app-home',
    templateUrl: './home.component.html'
})

export class HomeComponent implements OnInit {

    // Sales Chart
    salesStatChartOptions:any = {
        series: {
            shadowSize: 0,
            curvedLines: {
                apply: true,
                active: true,
                monotonicFit: true
            },
            points: {
                show: false
            }
        },
        grid: {
            borderWidth: 1,
            borderColor: '#edf9fc',
            show: true,
            hoverable: true,
            clickable: true
        },
        xaxis: {
            tickColor: '#edf9fc',
            tickDecimals: 0,
            font: {
                lineHeight: 13,
                style: 'normal',
                color: '#999999',
                size: 11
            }
        },
        yaxis: {
            tickColor: '#edf9fc',
            font: {
                lineHeight: 13,
                style: 'normal',
                color: '#999999',
                size: 11,
            },
            min: +5
        },
        legend:{
            container: '.flot-chart-legends--curved',
            backgroundOpacity: 0.5,
            noColumns: 0,
            backgroundColor: '#fff',
            lineWidth: 0,
            labelBoxBorderColor: '#fff'
        }
    };

    salesStatChartData:any = [
        {
            label: 'Grey',
            color: '#f6f6f6',
            lines: {
                show: true,
                lineWidth: 0,
                fill: 1,
                fillColor: {
                    colors: ['rgba(246,246,246,0.1)', '#f6f6f6']
                }
            },
            data: [[10, 90], [20, 40], [30, 80], [40, 20], [50, 90], [60, 20], [70, 60]],

        },
        {
            label: 'Cyan',
            color: '#00BCD4',
            lines: {
                show: true,
                lineWidth: 0.1,
                fill: 1,
                fillColor: {
                    colors: ['rgba(0,188,212,0.001)', '#00BCD4']
                }
            },
            data: [[10, 80], [20, 30], [30, 70], [40, 10], [50, 80], [60, 10], [70, 50]]
        }
    ];

    // Line Chart
    lineChartOptions: any = {
        series: {
            lines: {
                show: true,
                barWidth: 0.05,
                fill: 0
            }
        },
        shadowSize: 0.1,
        grid : {
            borderWidth: 1,
            borderColor: '#edf9fc',
            show : true,
            hoverable : true,
            clickable : true
        },

        yaxis: {
            tickColor: '#edf9fc',
            tickDecimals: 0,
            font :{
                lineHeight: 13,
                style: 'normal',
                color: '#9f9f9f',
            },
            shadowSize: 0
        },

        xaxis: {
            tickColor: '#fff',
            tickDecimals: 0,
            font :{
                lineHeight: 13,
                style: 'normal',
                color: '#9f9f9f'
            },
            shadowSize: 0,
        },
        legend:{
            container: '.flot-chart-legends--lines',
            backgroundOpacity: 0.5,
            noColumns: 0,
            backgroundColor: '#fff',
            lineWidth: 0,
            labelBoxBorderColor: '#fff'
        }
    };

    lineChartData: any = [
        {
            label: 'Green',
            data: [[1,60], [2,30], [3,50], [4,100], [5,10], [6,90], [7,85]],
            color: '#32c787'
        },
        {
            label: 'Blue',
            data: [[1,20], [2,90], [3,60], [4,40], [5,100], [6,25], [7,65]],
            color: '#03A9F4'
        },
        {
            label: 'Amber',
            data: [[1,100], [2,20], [3,60], [4,90], [5,80], [6,10], [7,5]],
            color: '#f5c942'
        }
    ]

    constructor() {

    }

    ngOnInit() {

    }

}
