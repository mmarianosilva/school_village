import React from 'react';
import { StyleSheet, Text, View, Button, TextInput, Alert, Dimensions } from 'react-native';
import Pdf from 'react-native-pdf';

export default class EMPDFViewer extends React.Component {

    static navigationOptions = {
        title: 'PDF View',
    };


    render() {
        const source = {uri:'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf',cache:true};
        console.log("Loading PDF");
        return (
            <View style={styles.container}>
                <Pdf
                    source={source}
                    onLoadComplete={(numberOfPages,filePath)=>{
                        console.log(`number of pages: ${numberOfPages}`);
                    }}
                    onPageChanged={(page,numberOfPages)=>{
                        console.log(`current page: ${page}`);
                    }}
                    onError={(error)=>{
                        console.log(error);
                    }}
                    style={styles.pdf}/>
            </View>
        )
  }
}


const styles = StyleSheet.create({
    splash: {
      flex: 1,
      backgroundColor: '#fff',
      alignItems: 'center',
      justifyContent: 'center'
    },
    button: {
      fontSize: 32
    },
    container: {
        flex: 1,
        justifyContent: 'flex-start',
        alignItems: 'center',
        marginTop: 25,
    },
    pdf: {
        flex:1,
        width:Dimensions.get('window').width,
    }
  });