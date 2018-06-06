import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';

import { CalendarComponent } from "./calendar.component";

const CALENDAR_ROUTES = [
    { path: '', component: CalendarComponent }
];

@NgModule ({
    declarations: [
        CalendarComponent
    ],
    imports: [
        CommonModule,
        RouterModule.forChild(CALENDAR_ROUTES)
    ]
})

export class CalendarModule {  }