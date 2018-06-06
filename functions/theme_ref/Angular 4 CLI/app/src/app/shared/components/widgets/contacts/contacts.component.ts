import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'widget-contacts',
  templateUrl: './contacts.component.html',
  styleUrls: ['./contacts.component.scss']
})
export class ContactsComponent implements OnInit {
  contactData: any;

  constructor() {
    this.contactData = {
      phone: '00971123456789',
      email: 'malinda.h@gmail.com',
      facebook: 'malinda.hollaway',
      twitter: '@malinda (twitter.com/malinda)',
      address: '44-46 Morningside Road,  Edinburgh, Scotland',
      map: './assets/demo/img/widgets/map.png'
    }
  }

  ngOnInit() {
  }

}
