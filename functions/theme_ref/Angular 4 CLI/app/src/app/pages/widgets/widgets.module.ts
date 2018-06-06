import { CommonModule } from "@angular/common";
import { RouterModule } from "@angular/router";
import { NgModule } from "@angular/core";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { SharedModule } from "../../shared/shared.module";

import { WidgetsComponent } from "./widgets.component";

const WIDGET_ROUTES = [
    { path: '', component: WidgetsComponent }
];

@NgModule ({
    declarations: [
        WidgetsComponent
    ],
    imports: [
        CommonModule,
        SharedModule,
        BsDropdownModule.forRoot(),
        RouterModule.forChild(WIDGET_ROUTES)
    ]
})

export class WidgetsModule {  }
