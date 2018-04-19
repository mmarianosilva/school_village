import React from 'react';
import { StyleSheet, Text, View, Button, TextInput, Alert } from 'react-native';

export default class Dashboard extends React.Component {

  static navigationOptions = {
    title: 'School Village',
  };

  render() {
    const { navigate } = this.props.navigation;

    return (
      <View style={styles.splash}>
          <Button style={styles.button} width="100" title='Send Alert' onPress={() => {
              Alert.alert('Sending Alert!');
          }}/>
          <Button style={styles.button} width="100" title='Em Prep PDF' onPress={() => {
              navigate('EMPDFViewer', { name: 'EM PDF' });
          }}/>
      </View>
    );
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
      fontSize: 32,
      marginTop: 8,
      padding: 8
    }
  });