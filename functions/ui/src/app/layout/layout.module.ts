import { CommonModule } from "@angular/common";
import { FormsModule } from "@angular/forms";

import { NgModule } from "@angular/core";
import { LayoutRouting } from "./layout.routing";
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';
import { ProgressbarModule } from 'ngx-bootstrap/progressbar';
import { ButtonsModule } from 'ngx-bootstrap';
import { PerfectScrollbarModule } from 'ngx-perfect-scrollbar';
import { PerfectScrollbarConfigInterface } from 'ngx-perfect-scrollbar';

import { LayoutComponent } from "./layout.component";
import { HeaderComponent } from './header/header.component';
import { SearchComponent } from './header/search/search.component';
import { NavigationComponent } from './navigation/navigation.component';
import { NavigationTriggerComponent } from './header/navigation-trigger/navigation-trigger.component';

const PERFECT_SCROLLBAR_CONFIG: PerfectScrollbarConfigInterface = {
  suppressScrollX: true
}

@NgModule ({
  declarations: [
    LayoutComponent,
    HeaderComponent,
    SearchComponent,
    NavigationComponent,
    NavigationTriggerComponent
  ],
  imports: [
    CommonModule,
    LayoutRouting,
    FormsModule,
    BsDropdownModule.forRoot(),
    ProgressbarModule.forRoot(),
    ButtonsModule.forRoot(),
    PerfectScrollbarModule.forRoot(PERFECT_SCROLLBAR_CONFIG)
  ]
})

export class LayoutModule {  }