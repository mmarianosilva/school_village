import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { AccordionModule } from 'ngx-bootstrap/accordion';

import { AccordionComponent } from './accordion.component';

const ACCORDION_ROUTES = [
    { path: '', component: AccordionComponent }
]

@NgModule ({
    declarations: [
        AccordionComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        AccordionModule.forRoot(),
        RouterModule.forChild(ACCORDION_ROUTES)
    ]
})

export class AccordionComponentModule {  }