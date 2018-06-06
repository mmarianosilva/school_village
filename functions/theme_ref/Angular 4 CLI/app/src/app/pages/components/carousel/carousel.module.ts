import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { CarouselModule } from 'ngx-bootstrap/carousel';

import { CarouselComponent } from "./carousel.component";

const CAROUSEL_ROUTES = [
    { path: '', component: CarouselComponent }
]

@NgModule ({
    declarations: [
        CarouselComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        CarouselModule.forRoot(),
        RouterModule.forChild(CAROUSEL_ROUTES)
    ]
})

export class CarouselComponentModule {  }