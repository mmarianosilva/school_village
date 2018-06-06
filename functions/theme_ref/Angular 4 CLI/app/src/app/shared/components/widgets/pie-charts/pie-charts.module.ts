import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { PieChartsComponent } from "./pie-charts.component";
import { EasyPieChartDirective } from "../../../directives/easy-pie-chart/easy-pie-chart.directive";

@NgModule ({
    declarations: [
        PieChartsComponent,
        EasyPieChartDirective
    ],
    imports: [
        CommonModule
    ]
})

export class PieChartsModule {}