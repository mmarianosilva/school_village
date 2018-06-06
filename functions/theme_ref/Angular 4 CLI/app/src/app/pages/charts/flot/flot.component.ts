import {Component, OnInit} from '@angular/core';

@Component({
    selector: 'app-flot',
    templateUrl: './flot.component.html',
    styleUrls: ['./flot.component.scss']
})
export class FlotComponent implements OnInit {
    // Curved edge chart
    curvedEdgeChartOptions: any = {
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
            borderColor: '#f8f8f8',
            show: true,
            hoverable: true,
            clickable: true
        },
        xaxis: {
            tickColor: '#f8f8f8',
            tickDecimals: 0,
            font: {
                lineHeight: 13,
                style: 'normal',
                color: '#bfbfbf',
                size: 11
            }
        },
        yaxis: {
            tickColor: '#f8f8f8',
            font: {
                lineHeight: 13,
                style: 'normal',
                color: '#bfbfbf',
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

    curvedEdgeChartData: any = [
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
            data: [[2011, 90], [2012, 40], [2013, 80], [2014, 20], [2015, 90], [2016, 20], [2017, 60]]
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
            data: [[2011, 80], [2012, 30], [2013, 70], [2014, 10], [2015, 80], [2016, 10], [2017, 50]]
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
            borderColor: '#f8f8f8',
            show : true,
            hoverable : true,
            clickable : true
        },

        yaxis: {
            tickColor: '#f8f8f8',
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


    // Bar Chart
    barChartOptions: any = {
        series: {
            bars: {
                show: true,
                barWidth: 0.05,
                fill: 1
            }
        },
        grid : {
            borderWidth: 1,
            borderColor: '#f8f8f8',
            show : true,
            hoverable : true,
            clickable : true
        },

        yaxis: {
            tickColor: '#f8f8f8',
            tickDecimals: 0,
            font :{
                lineHeight: 13,
                style: "normal",
                color: "#9f9f9f",
            },
            shadowSize: 0
        },

        xaxis: {
            tickColor: '#fff',
            tickDecimals: 0,
            font :{
                lineHeight: 13,
                style: "normal",
                color: "#9f9f9f"
            },
            shadowSize: 0,
        },

        legend:{
            container: '.flot-chart-legends--bar',
            backgroundOpacity: 0.5,
            noColumns: 0,
            backgroundColor: '#fff',
            lineWidth: 0,
            labelBoxBorderColor: '#fff'
        }
    };

    barChartData = [
        {
            label: 'Green',
            data: [[1,60], [2,30], [3,50], [4,100], [5,10], [6,90], [7,85]],
            color: '#32c787',
            bars: {
                order: 0
            }
        },
        {
            label: 'Blue',
            data: [[1,20], [2,90], [3,60], [4,40], [5,100], [6,25], [7,65]],
            color: '#03A9F4',
            bars: {
                order: 1
            }
        },
        {
            label: 'Amber',
            data: [[1,100], [2,20], [3,60], [4,90], [5,80], [6,10], [7,5]],
            color: '#f5c942',
            bars: {
                order: 2
            }
        }
    ]


    // Pie Chart
    pieChartOptions: any = {
        series: {
            pie: {
                show: true,
                stroke: {
                    width: 2,
                },
            },
        },
        grid: {
            hoverable: true,
            clickable: true
        },
        tooltip: true,
        tooltipOpts: {
            content: "%p.0%, %s", // show percentages, rounding to 2 decimal places
            shifts: {
                x: 20,
                y: 0
            },
            defaultTheme: false,
            cssClass: 'flot-tooltip'
        },
        legend: {
            container: '.flot-chart-legends--pie',
            backgroundOpacity: 0.5,
            noColumns: 0,
            backgroundColor: "white",
            lineWidth: 0,
            labelBoxBorderColor: '#fff'
        }
    };

    pieChartData: any = [
        { data: 1, color: '#ff6b68', label: 'Toyota' },
        { data: 2, color: '#03A9F4', label: 'Nissan' },
        { data: 3, color: '#32c787', label: 'Hyundai' },
        { data: 4, color: '#f5c942', label: 'Scion' },
        { data: 4, color: '#d066e2', label: 'Daihatsu' },
    ];

    constructor() {
    }

    ngOnInit() {
    }

}
