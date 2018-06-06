import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from "@angular/router";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { IconsComponent } from "./icons.component";

const ICONS_ROUTES = [
    { path: '', component: IconsComponent }
];

@NgModule ({
    declarations: [
        IconsComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(ICONS_ROUTES)
    ]
})

export class IconsModule {  }