import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { SharedModule } from "../../shared/shared.module";

import { HomeComponent } from "./home.component";
import { QuickStatsComponent } from './quick-stats/quick-stats.component';

const HOME_ROUTE = [
    { path: '', component: HomeComponent }
];

@NgModule ({
    declarations: [
        HomeComponent,
        QuickStatsComponent
    ],
    imports: [
        CommonModule,
        SharedModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(HOME_ROUTE)
    ]
})

export class HomeModule {  }