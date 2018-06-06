import { Routes, RouterModule } from '@angular/router';
import { LayoutComponent } from './layout.component';

const LAYOUT_ROUTES: Routes = [
    { path: '', component: LayoutComponent, children: [
        //Home
        { path: '', redirectTo: 'home', pathMatch: 'full' },
        { path: 'home', loadChildren: '../pages/home/home.module#HomeModule' },

        // Typography
        { path: 'typography', loadChildren: '../pages/typography/typography.module#TypographyModule' },

        // Widgets
        { path: 'widgets', loadChildren: '../pages/widgets/widgets.module#WidgetsModule' },

        // Tables
        { path: 'table/table', loadChildren: '../pages/table/table/table.module#TableModule' },
        { path: 'table/data-table', loadChildren: '../pages/table/data-table/data-table.module#DataTableModule' },

        // Forms
        { path: 'form/form-elements', loadChildren: '../pages/form/form-elements/form-elements.module#FormElementsModule' },
        { path: 'form/form-components', loadChildren: '../pages/form/form-components/form-components.module#FormComponentsModule' },
        { path: 'form/form-validation', loadChildren: '../pages/form/form-validation/form-validation.module#FormValidationModule' },

        // User Interface
        { path: 'user-interface/colors', loadChildren: '../pages/user-interface/colors/colors.module#ColorsModule' },
        { path: 'user-interface/css-animations', loadChildren: '../pages/user-interface/css-animations/css-animations.module#CssAnimationsModule' },
        { path: 'user-interface/buttons', loadChildren: '../pages/user-interface/buttons/buttons.module#ButtonsModule' },
        { path: 'user-interface/icons', loadChildren: '../pages/user-interface/icons/icons.module#IconsModule' },
        { path: 'user-interface/cards', loadChildren: '../pages/user-interface/cards/cards.module#CardsModule' },
        { path: 'user-interface/alerts', loadChildren: '../pages/user-interface/alerts/alerts.module#AlertsModule' },
        { path: 'user-interface/badges', loadChildren: '../pages/user-interface/badges/badges.module#BadgesModule' },
        { path: 'user-interface/breadcrumbs', loadChildren: '../pages/user-interface/breadcrumb/breadcrumb.module#BreadcrumbModule' },
        { path: 'user-interface/jumbotron', loadChildren: '../pages/user-interface/jumbotron/jumbotron.module#JumbotronModule' },
        { path: 'user-interface/navs', loadChildren: '../pages/user-interface/navs/navs.module#NavsModule' },
        { path: 'user-interface/pagination', loadChildren: '../pages/user-interface/pagination/pagination.module#PaginationsModule' },

        // Components
        { path: 'components/accordion', loadChildren: '../pages/components/accordion/accordion.module#AccordionComponentModule' },
        { path: 'components/alerts', loadChildren: '../pages/components/alerts/alerts.module#AlertsComponentModule' },
        { path: 'components/buttons', loadChildren: '../pages/components/buttons/buttons.module#ButtonsComponentModule' },
        { path: 'components/carousel', loadChildren: '../pages/components/carousel/carousel.module#CarouselComponentModule' },
        { path: 'components/collapse', loadChildren: '../pages/components/collapse/collapse.module#CollapseComponentModule' },
        { path: 'components/dropdowns', loadChildren: '../pages/components/dropdowns/dropdowns.module#DropdownComponentModule' },
        { path: 'components/modals', loadChildren: '../pages/components/modals/modals.module#ModalsModule' },
        { path: 'components/popover', loadChildren: '../pages/components/popover/popover.module#PopoverComponentModule' },
        { path: 'components/progressbar', loadChildren: '../pages/components/progressbar/progressbar.module#ProgressbarComponentModule' },
        { path: 'components/rating', loadChildren: '../pages/components/rating/rating.module#RatingComponentModule' },
        { path: 'components/sortable', loadChildren: '../pages/components/sortable/sortable.module#SortableComponentModule' },
        { path: 'components/tabs', loadChildren: '../pages/components/tabs/tabs.module#TabsComponentModule' },
        { path: 'components/tooltips', loadChildren: '../pages/components/tooltips/tooltips.module#TooltipsComponentModule' },
        { path: 'components/typeahead', loadChildren: '../pages/components/typeahead/typeahead.module#TypeaheadComponentModule' },
        { path: 'components/datepicker', loadChildren: '../pages/components/datepicker/datepicker.module#DatepickerComponentModule' },
        { path: 'components/pagination', loadChildren: '../pages/components/pagination/pagination.module#PaginationComponentModule' },
        { path: 'components/time-picker', loadChildren: '../pages/components/time-picker/time-picker.module#TimepickerComponentModule' },

        // Charts
        { path: 'charts/flot', loadChildren: '../pages/charts/flot/flot.module#FlotModule' },
        { path: 'charts/sparklines', loadChildren: '../pages/charts/sparklines/sparklines.module#SparklineModule' },

        // Calendar
        { path: 'calendar', loadChildren: '../pages/calendar/calendar.module#CalendarModule' },

        // Sample Pages'
        { path: 'sample-pages', loadChildren: '../pages/sample-pages/sample-pages.module#SamplePagesModule' }


    ]}
];

export const LayoutRouting = RouterModule.forChild(LAYOUT_ROUTES);