import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { TabsModule } from 'ngx-bootstrap/tabs';

import { TabsComponent } from "./tabs.component";

const TABS_ROUTES = [
    { path: '', component: TabsComponent }
]

@NgModule ({
    declarations: [
        TabsComponent
    ],
    imports: [
        CommonModule,
        BsDropdownModule.forRoot(),
        TabsModule.forRoot(),
        RouterModule.forChild(TABS_ROUTES)
    ]
})

export class TabsComponentModule {  }