import { CommonModule } from '@angular/common';
import { FormsModule } from "@angular/forms";
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { DatepickerModule } from 'ngx-bootstrap/datepicker';

import { DatepickerComponent } from "./datepicker.component";

const DATEPICKER_ROUTES = [
    { path: '', component: DatepickerComponent }
]

@NgModule ({
    declarations: [
        DatepickerComponent
    ],
    imports: [
        CommonModule,
        FormsModule,
        BsDropdownModule.forRoot(),
        DatepickerModule.forRoot(),
        RouterModule.forChild(DATEPICKER_ROUTES)
    ]
})

export class DatepickerComponentModule {  }