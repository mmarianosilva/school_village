import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

import { EasyPieChartDirective } from "./directives/easy-pie-chart/easy-pie-chart.directive";
import { JqvMapDirective } from "./directives/jqvmap/jqvmap.directive";
import { FlotDirective } from "./directives/flot/flot.directive";
import { SparklineDirective } from "./directives/sparklines/sparkline.directive";
import { DropzoneDirective } from "./directives/dropzone/dropzone.directive";
import { InputFloatDirective } from "./directives/input-float/input-float.directive";

import { TodoListsComponent } from "./components/widgets/todo-lists/todo-lists.component";
import { PieChartsComponent } from "./components/widgets/pie-charts/pie-charts.component";
import { RandomPostComponent } from "./components/widgets/random-post/random-post.component";
import { RecentPostsComponent } from "./components/widgets/recent-posts/recent-posts.component";
import { VisitorsComponent } from "./components/widgets/visitors/visitors.component";
import { PastDaysComponent } from "./components/widgets/past-days/past-days.component";
import { PhotosComponent } from './components/widgets/photos/photos.component';
import { TasksComponent } from './components/widgets/tasks/tasks.component';
import { ContactsComponent } from './components/widgets/contacts/contacts.component';
import { RatingsComponent } from './components/widgets/ratings/ratings.component';
import { ProfileComponent } from './components/widgets/profile/profile.component';
import { RecentSignupsComponent } from './components/widgets/recent-signups/recent-signups.component';

@NgModule ({
  declarations: [
    // Directives
    EasyPieChartDirective,
    JqvMapDirective,
    FlotDirective,
    SparklineDirective,
    DropzoneDirective,
    InputFloatDirective,

    // Components
    PastDaysComponent,
    TodoListsComponent,
    PieChartsComponent,
    RandomPostComponent,
    RecentPostsComponent,
    VisitorsComponent,
    PhotosComponent,
    TasksComponent,
    ContactsComponent,
    RatingsComponent,
    ProfileComponent,
    RecentSignupsComponent
  ],
  imports: [
    CommonModule,
    RouterModule,
    BsDropdownModule.forRoot()
  ],
  exports: [
    // Directives
    EasyPieChartDirective,
    JqvMapDirective,
    FlotDirective,
    SparklineDirective,
    DropzoneDirective,
    InputFloatDirective,

    // Components
    PastDaysComponent,
    TodoListsComponent,
    PieChartsComponent,
    RandomPostComponent,
    RecentPostsComponent,
    VisitorsComponent,
    PhotosComponent,
    TasksComponent,
    ContactsComponent,
    RatingsComponent,
    ProfileComponent,
    RecentSignupsComponent,
  ]
})

export class SharedModule {  }