import { Directive, Input, ElementRef } from '@angular/core';

declare var jQuery: any;

@Directive ({
    selector: '[JqvMap]'
})

export class JqvMapDirective {
    @Input() private options:any;
    @Input() private height:any;

    constructor (private el: ElementRef) { }

    ngOnInit() {
        let initJqvMap = jQuery(this.el.nativeElement);

        initJqvMap.css ({
            height: this.height,
            width: '100%'
        });

        initJqvMap.vectorMap(
            this.options
        );
    }
}
