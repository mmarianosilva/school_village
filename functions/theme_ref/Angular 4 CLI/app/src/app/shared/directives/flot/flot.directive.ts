import { Directive, Input, ElementRef } from "@angular/core";

declare var jQuery: any;

@Directive ({
    selector: '[flot]',
    host: {
        '(window:resize)': 'onResize($event)'
    }
})

export class FlotDirective {
    @Input() private options:any;
    @Input() private dataset:any;
    @Input() private height:string;
    initFlot:any = jQuery(this.el.nativeElement);

    constructor (private el: ElementRef) { }

    onResize() {
        this.initFlot.plot(
            this.dataset,
            this.options
        )
    }

    ngOnInit() {
        this.initFlot.css({
            height: this.height
        });

        jQuery.plot (
            this.initFlot,
            this.dataset,
            this.options
        );

        // Tooltips
        this.initFlot.on('plothover', function (event, pos, item) {
            if (item) {
                var x = item.datapoint[0].toFixed(2),
                    y = item.datapoint[1].toFixed(2);
                jQuery('.flot-tooltip').html(item.series.label + ' of ' + x + ' = ' + y).css({top: item.pageY+5, left: item.pageX+5}).show();
            }
            else {
                jQuery('.flot-tooltip').hide();
            }
        });
        jQuery('body').append('<div class="flot-tooltip" />');
    }
}