import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';

import { SamplePagesComponent } from "./sample-pages.component";

const SAMPLE_PAGES_ROUTES = [
    { path: '', component: SamplePagesComponent }
];

@NgModule ({
    declarations: [
        SamplePagesComponent
    ],
    imports: [
        CommonModule,
        RouterModule.forChild(SAMPLE_PAGES_ROUTES)
    ]
})

export class SamplePagesModule {  }