import { Component, OnInit } from '@angular/core';
import { SharedService } from "../../shared/services/shared.service";

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: [
    './header.component.scss'
  ]
})
export class HeaderComponent implements OnInit {
  messagesData: Array<any>;
  tasksData: Array<any>;
  maThemeModel: string = 'green';

  setTheme() {
    this.sharedService.setTheme(this.maThemeModel)
  }

  constructor(private sharedService: SharedService) {
    sharedService.maThemeSubject.subscribe((value) => {
      this.maThemeModel = value
    })

    this.messagesData = [
      {
        image: './assets/demo/img/profile-pics/1.jpg',
        name: 'David Belle',
        message: 'Cum sociis natoque penatibus et magnis dis parturient montes',
        date: '12:01 PM'
      },
      {
        image: './assets/demo/img/profile-pics/2.jpg',
        name: 'Jonathan Morris',
        message: 'Nunc quis diam diamurabitur at dolor elementum, dictum turpis vel',
        date: '02:45 PM'
      },
      {
        image: './assets/demo/img/profile-pics/6.jpg',
        name: 'Fredric Mitchell Jr.',
        message: 'Phasellus a ante et est ornare accumsan at vel magnauis blandit turpis at augue ultricies',
        date: '08:21 PM'
      },
      {
        image: './assets/demo/img/profile-pics/4.jpg',
        name: 'Glenn Jecobs',
        message: 'Ut vitae lacus sem ellentesque maximus, nunc sit amet varius dignissim, dui est consectetur neque',
        date: '08:43 PM'
      },
      {
        image: './assets/demo/img/profile-pics/5.jpg',
        name: 'Bill Phillips',
        message: 'Proin laoreet commodo eros id faucibus. Donec ligula quam, imperdiet vel ante placerat',
        date: '11:32 PM'
      }
    ];

    this.tasksData = [
      {
        name: 'HTML5 Validation Report',
        completed: 95,
        color: ''
      },{
        name: 'Google Chrome Extension',
        completed: '80',
        color: 'success'
      },{
        name: 'Social Intranet Projects',
        completed: '20',
        color: 'warning'
      },{
        name: 'Bootstrap Admin Template',
        completed: '60',
        color: 'danger'
      },{
        name: 'Youtube Client App',
        completed: '80',
        color: 'info'
      }
    ]
  }

  ngOnInit() {

  }
}