import { Component, OnInit } from '@angular/core';
import { SharedService } from "../../../shared/services/shared.service";

@Component({
    selector: 'navigation-trigger',
    templateUrl: './navigation-trigger.component.html',
    styleUrls: ['./navigation-trigger.component.scss'],
})
export class NavigationTriggerComponent implements OnInit {
    sidebarVisible: boolean;

    constructor(private sharedService: SharedService) {
        sharedService.sidebarVisibilitySubject.subscribe((value) => {
            this.sidebarVisible = value
        })
    }

    toggleSidebarVisibility() {
        this.sharedService.toggleSidebarVisibilty()
    }

    ngOnInit() {

    }
}
